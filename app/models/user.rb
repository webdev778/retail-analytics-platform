class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :marketplaces, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :inventory_data_uploads, dependent: :destroy
  has_many :inventories, dependent: :destroy
  has_many :reports, dependent: :destroy

  def marketplace_connected?
    marketplaces.present?
  end
end
