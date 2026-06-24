create table if not exists public.daily_records (user_id uuid references auth.users(id) on delete cascade not null,record_date date not null,checked jsonb not null default '{}'::jsonb,note text not null default '',photos jsonb not null default '[]'::jsonb,primary key (user_id,record_date));
alter table public.daily_records enable row level security;
create policy "user data only" on public.daily_records for all to authenticated using (auth.uid()=user_id) with check (auth.uid()=user_id);
insert into storage.buckets (id,name,public) values ('daily-photos','daily-photos',true) on conflict (id) do nothing;
create policy "upload own" on storage.objects for insert to authenticated with check (bucket_id='daily-photos' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "delete own" on storage.objects for delete to authenticated using (bucket_id='daily-photos' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "read photos" on storage.objects for select to public using (bucket_id='daily-photos');
