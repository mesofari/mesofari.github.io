-- Kai Music Lounge: proposed initial schema for a NEW Supabase project.
-- Review and test in a staging project before using on production.
create extension if not exists pgcrypto;
create table if not exists public.lounge_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default 'Community-Mitglied' check (char_length(display_name) between 2 and 40),
 xp bigint not null default 0 check (xp >= 0),
 created_at timestamptz not null default now()
);
create table if not exists public.lounge_events (
 id uuid primary key default gen_random_uuid(),
 title text not null check (char_length(title) between 3 and 120),
 description text not null default '',
 starts_at timestamptz not null,
 submissions_open boolean not null default false,
 capacity integer not null default 30 check(capacity between 1 and 500),
 created_at timestamptz not null default now()
);
create table if not exists public.lounge_songs (
 id uuid primary key default gen_random_uuid(),
 event_id uuid not null references public.lounge_events(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 title text not null check (char_length(title) between 1 and 120),
 song_url text not null check(song_url ~* '^https://[^[:space:]]{5,1000}$'),
 story text not null default '' check(char_length(story) <= 2000),
 status text not null default 'pending' check(status in ('pending','approved','rejected','played')),
 submitted_at timestamptz not null default now(),
 unique(event_id,user_id)
);
create table if not exists public.lounge_xp_ledger (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 source text not null check(source in ('song','support','adjustment')),
 source_id uuid not null,
 xp_delta bigint not null check(xp_delta <> 0),
 created_at timestamptz not null default now(),
 unique(source,source_id)
);
create table if not exists public.lounge_supports (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 amount_cents bigint not null check(amount_cents > 0),
 transfer_reference text not null unique,
 verified_at timestamptz not null default now(),
 verified_by uuid,
 xp_awarded bigint not null check(xp_awarded >= 0)
);
-- First 5 levels fast; after level 5 progressively harder.
-- Returns total XP required to REACH a particular level (1=0, 50=...).
create or replace function public.lounge_xp_threshold(target_level integer)
returns bigint language sql immutable set search_path = ''
as $$
 select case when target_level <= 1 then 0
             when target_level > 50 then null
             else (select coalesce(sum(
               case when lvl <= 5 then 10
               else 10 + (lvl - 5) * 5
               end),0)::bigint
               from generate_series(2,target_level) as lvl) end
$$;
create or replace function public.lounge_level(total_xp bigint)
returns integer language sql immutable set search_path = ''
as $$
 select coalesce((select max(lvl) from generate_series(1,50) as lvl
 where public.lounge_xp_threshold(lvl) <= greatest(total_xp,0)),1)
$$;
-- profile is automatically created after registration
create or replace function public.lounge_create_profile()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
 insert into public.lounge_profiles(user_id,display_name)
 values(new.id, 'Mitglied-' || left(new.id::text,8))
 on conflict(user_id) do nothing;
 return new;
end $$;
drop trigger if exists lounge_new_user on auth.users;
create trigger lounge_new_user after insert on auth.users
for each row execute function public.lounge_create_profile();
-- Server awards XP exactly once for the first submission to an event.
create or replace function public.lounge_award_song_xp()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
 insert into public.lounge_xp_ledger(user_id,source,source_id,xp_delta)
 values(new.user_id,'song',new.id,10);
 update public.lounge_profiles set xp=xp+10 where user_id=new.user_id;
 return new;
end $$;
drop trigger if exists lounge_song_xp on public.lounge_songs;
create trigger lounge_song_xp after insert on public.lounge_songs
for each row execute function public.lounge_award_song_xp();
-- Verify event is open and capacity available. Locks the event row for
-- serialization so two concurrent submissions cannot exceed its capacity.
create or replace function public.lounge_check_submission()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare e record;
begin
 if auth.uid() is null or new.user_id <> auth.uid() then
   raise exception 'Not permitted';
 end if;
 select * into e from public.lounge_events where id=new.event_id for update;
 if not found or not e.submissions_open then raise exception 'Einreichungen geschlossen'; end if;
 if (select count(*) from public.lounge_songs where event_id=new.event_id) >= e.capacity then
   raise exception 'Alle Plätze belegt';
 end if;
 return new;
end $$;
drop trigger if exists lounge_validate_submission on public.lounge_songs;
create trigger lounge_validate_submission before insert on public.lounge_songs
for each row execute function public.lounge_check_submission();
-- Service role ONLY after manually checking N26 incoming transactions.
-- Fractional amounts are floored to whole EUR, e.g. 1.99 EUR => 1 XP.
-- idempotency via unique transfer_reference. No public payment-success endpoint.
create or replace function public.lounge_confirm_support(
 p_user_id uuid, p_amount_cents bigint, p_transfer_reference text, p_verified_by uuid default null
) returns bigint language plpgsql security definer set search_path = ''
as $$
declare v_id uuid; v_xp bigint;
begin
 if auth.role() <> 'service_role' then raise exception 'Service only'; end if;
 if p_user_id is null or p_amount_cents <= 0 or char_length(trim(p_transfer_reference)) < 5 then
   raise exception 'Invalid verified transfer'; end if;
 v_xp := p_amount_cents / 100;
 insert into public.lounge_supports(user_id,amount_cents,transfer_reference,verified_by,xp_awarded)
 values(p_user_id,p_amount_cents,trim(p_transfer_reference),p_verified_by,v_xp)
 returning id into v_id;
 if v_xp > 0 then
   insert into public.lounge_xp_ledger(user_id,source,source_id,xp_delta)
   values(p_user_id,'support',v_id,v_xp);
   update public.lounge_profiles set xp=xp+v_xp where user_id=p_user_id;
 end if;
 return v_xp;
end $$;
-- public profiles intentionally contain no email, payment reference or history.
alter table public.lounge_profiles enable row level security;
alter table public.lounge_events enable row level security;
alter table public.lounge_songs enable row level security;
alter table public.lounge_xp_ledger enable row level security;
alter table public.lounge_supports enable row level security;
revoke all on public.lounge_profiles,public.lounge_events,public.lounge_songs,
 public.lounge_xp_ledger,public.lounge_supports from anon,authenticated;
grant select on public.lounge_profiles,public.lounge_events to anon,authenticated;
grant select,insert on public.lounge_songs to authenticated;
grant select on public.lounge_xp_ledger to authenticated;
create policy "All can see public levels" on public.lounge_profiles for select to anon,authenticated using(true);
create policy "All can view event schedule" on public.lounge_events for select to anon,authenticated using(true);
create policy "Users see own songs" on public.lounge_songs for select to authenticated using(user_id=(select auth.uid()));
create policy "Users submit own song" on public.lounge_songs for insert to authenticated
 with check(user_id=(select auth.uid()) and status='pending');
create policy "Users see own XP history" on public.lounge_xp_ledger for select to authenticated using(user_id=(select auth.uid()));
-- Public queue: only approved or played songs; no private stories.
create or replace function public.lounge_public_queue(p_event uuid)
returns table(song_id uuid, song_title text, display_name text, submitted_at timestamptz, status text)
language sql stable security definer set search_path = ''
as $$
 select s.id,s.title,p.display_name,s.submitted_at,s.status
 from public.lounge_songs s join public.lounge_profiles p on p.user_id=s.user_id
 where s.event_id=p_event and s.status in ('approved','played')
 order by s.submitted_at,s.id
$$;
revoke execute on function public.lounge_confirm_support(uuid,bigint,text,uuid) from public,anon,authenticated;
grant execute on function public.lounge_confirm_support(uuid,bigint,text,uuid) to service_role;
revoke execute on function public.lounge_public_queue(uuid) from public;
grant execute on function public.lounge_public_queue(uuid) to anon,authenticated;
revoke execute on function public.lounge_create_profile() from public,anon,authenticated;
revoke execute on function public.lounge_award_song_xp() from public,anon,authenticated;
revoke execute on function public.lounge_check_submission() from public,anon,authenticated;
-- SECURITY: set up protected admin event approval/status operations separately.
-- NO service-role key in public website. No admin privileges derived from user metadata.
