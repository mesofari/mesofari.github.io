-- Kai Music Lounge, Supabase project: kai-music-lounge
-- Database created by Supabase migrations on 17 November 2026.
-- DO NOT RUN the old sample schema again: the production database now
-- uses a separate private schema with secure server-side XP transactions.
-- This file is a READ-ONLY diagnostic, safe to run in Supabase SQL Editor.
select n.nspname as schema_name, c.relname as table_name,c.relrowsecurity as rls_on
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname in ('public','lounge_private') and c.relkind='r' and c.relname like 'lounge_%'
order by 1,2;
select public.lounge_level(0) as level_0,public.lounge_level(40) as level_40,public.lounge_level(5665) as level_5665;
