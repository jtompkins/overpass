create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp without time zone,
  display_name text not null,
  avatar_url text,
  following_count integer,
  follower_count integer,
  public boolean default false
);

alter table profiles
  enable row level security;

create policy "Profiles are visible to their owners or if they are public" on profiles
  for select using (public is true OR auth.uid() = id);

create policy "Profiles can be inserted by their owners" on profiles
  for insert with check (auth.uid() = id);

create policy "Profiles can be updated by their owners" on profiles
  for update using (auth.uid() = id);
