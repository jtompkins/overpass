create table urls (
  id integer primary key generated always as identity,
  url text not null,
  title text not null,
  created_at timestamp without time zone default now()
);

create table posts (
  id integer primary key generated always as identity,
  user_id uuid references auth.users,
  url_id integer references urls,
  created_at timestamp without time zone default now(),
  public boolean default false
);

alter table posts
  enable row level security;

create policy "Posts are visible to their owners or if they are public" on posts
  for select using (public is true OR auth.uid() = user_id);

create policy "Posts can be inserted by their owners" on posts
  for insert with check (auth.uid() = user_id);

create policy "Posts can be updated by their owners" on posts
  for update using (auth.uid() = user_id);
