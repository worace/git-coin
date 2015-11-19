Sequel.migration do
  up do
    drop_table(:posse_awards)
  end

  down do
    create_table(:posse_awards) do
      primary_key :id
      Integer :value
      String :posse
      DateTime :created_at
    end
  end
end
