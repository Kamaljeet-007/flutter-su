-- Create users table for storing additional user information
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  full_name text,
  is_admin boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Create tickets table
create table public.tickets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  description text not null,
  category text not null,
  priority text not null,
  status text not null default 'open',
  attachments text[] default array[]::text[],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.tickets enable row level security;

-- Create ticket comments table
create table public.ticket_comments (
  id uuid default gen_random_uuid() primary key,
  ticket_id uuid references public.tickets(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  comment text not null,
  is_admin_comment boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.ticket_comments enable row level security;

-- Create RLS policies

-- Profiles policies
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Tickets policies
create policy "Users can view their own tickets"
  on public.tickets for select
  using (auth.uid() = user_id or exists (
    select 1 from public.profiles
    where id = auth.uid() and is_admin = true
  ));

create policy "Users can create tickets"
  on public.tickets for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own tickets"
  on public.tickets for update
  using (auth.uid() = user_id or exists (
    select 1 from public.profiles
    where id = auth.uid() and is_admin = true
  ));

-- Comments policies
create policy "Users can view comments on their tickets"
  on public.ticket_comments for select
  using (exists (
    select 1 from public.tickets
    where tickets.id = ticket_id
    and (tickets.user_id = auth.uid() or exists (
      select 1 from public.profiles
      where id = auth.uid() and is_admin = true
    ))
  ));

create policy "Users can create comments on their tickets"
  on public.ticket_comments for insert
  with check (exists (
    select 1 from public.tickets
    where tickets.id = ticket_id
    and (tickets.user_id = auth.uid() or exists (
      select 1 from public.profiles
      where id = auth.uid() and is_admin = true
    ))
  ));

-- Create functions and triggers
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user creation
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Function to update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Triggers for updated_at
create trigger handle_updated_at
  before update on public.profiles
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at
  before update on public.tickets
  for each row execute procedure public.handle_updated_at();