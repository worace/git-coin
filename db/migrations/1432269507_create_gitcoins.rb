Sequel.migration do
  up do
    create_table(:coins) do
      primary_key :id
      String :owner
      Integer :value
    end
  end

  down do
    drop_table(:coins)
  end
end
