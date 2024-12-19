CREATE TABLE tasks (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title text NOT NULL,
    description text,
    status text NOT NULL DEFAULT 'pending',
    priority text NOT NULL DEFAULT 'medium',
    due_date timestamp with time zone,
    assignee uuid REFERENCES auth.users(id),
    matter_id bigint REFERENCES matters(id) ON DELETE CASCADE,
    created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create indexes
CREATE INDEX tasks_matter_id_idx ON tasks(matter_id);
CREATE INDEX tasks_created_by_idx ON tasks(created_by);
CREATE INDEX tasks_assignee_idx ON tasks(assignee);

-- Enable RLS
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view tasks in their matters"
    ON tasks FOR SELECT
    USING (
        matter_id IN (
            SELECT id FROM matters WHERE created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create tasks in their matters"
    ON tasks FOR INSERT
    WITH CHECK (
        matter_id IN (
            SELECT id FROM matters WHERE created_by = auth.uid()
        )
    );

CREATE POLICY "Users can update tasks in their matters"
    ON tasks FOR UPDATE
    USING (
        matter_id IN (
            SELECT id FROM matters WHERE created_by = auth.uid()
        )
    );

CREATE POLICY "Users can delete tasks in their matters"
    ON tasks FOR DELETE
    USING (
        matter_id IN (
            SELECT id FROM matters WHERE created_by = auth.uid()
        )
    );

-- Create trigger for updated_at
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 