Sequel.migration do
  up do
    alter_table(:debits) do
      add_column(:posse_award_id, Integer)
    end
  end

  down do
    drop_column :debits, :posse_award_id
  end
end
