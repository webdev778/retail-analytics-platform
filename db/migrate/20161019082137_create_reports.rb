class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.belongs_to :user, index: true
      t.belongs_to :marketplace, index: true

      t.string :generated_report_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer :report_type
      t.boolean :processed

      t.timestamps
    end
  end
end
