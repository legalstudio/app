-- Create matters table
CREATE TABLE matters (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title varchar NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX matters_created_by_idx ON matters(created_by);

-- Enable RLS
ALTER TABLE matters ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own matters" 
    ON matters FOR SELECT 
    USING (auth.uid() = created_by);

CREATE POLICY "Users can insert their own matters" 
    ON matters FOR INSERT 
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update their own matters" 
    ON matters FOR UPDATE 
    USING (auth.uid() = created_by);

CREATE POLICY "Users can delete their own matters" 
    ON matters FOR DELETE 
    USING (auth.uid() = created_by);

-- Create trigger for updated_at
CREATE TRIGGER update_matters_updated_at
    BEFORE UPDATE ON matters
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 