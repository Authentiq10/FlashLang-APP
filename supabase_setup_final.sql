-- FlashLang Supabase Setup (Final - No Conflicts)
-- This works with Supabase's built-in authentication system

-- Create a user profiles table to store additional user data
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_profiles
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile" ON public.user_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- Grant permissions on user_profiles
GRANT ALL ON public.user_profiles TO anon, authenticated;

-- Create a table for user learning progress (for your flashcard app)
CREATE TABLE IF NOT EXISTS public.user_learning_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    flashcard_id TEXT NOT NULL,
    learning_status TEXT NOT NULL CHECK (learning_status IN ('new', 'familiar', 'learned')),
    last_reviewed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, flashcard_id)
);

-- Enable RLS on learning progress
ALTER TABLE public.user_learning_progress ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for learning progress
CREATE POLICY "Users can view own learning progress" ON public.user_learning_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own learning progress" ON public.user_learning_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own learning progress" ON public.user_learning_progress
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own learning progress" ON public.user_learning_progress
    FOR DELETE USING (auth.uid() = user_id);

-- Grant permissions on learning progress
GRANT ALL ON public.user_learning_progress TO anon, authenticated;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX IF NOT EXISTS idx_learning_progress_user_id ON public.user_learning_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_progress_flashcard_id ON public.user_learning_progress(flashcard_id);
CREATE INDEX IF NOT EXISTS idx_learning_progress_status ON public.user_learning_progress(learning_status);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_learning_progress_updated_at
    BEFORE UPDATE ON public.user_learning_progress
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Note: We don't create a trigger on auth.users because Supabase manages this internally
-- User profiles can be created manually when needed, or you can use Supabase's built-in
-- user management features to handle profile creation. 