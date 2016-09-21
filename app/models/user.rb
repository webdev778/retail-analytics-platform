class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :inventory_data_uploads
  has_one :account
  has_one :marketplace
  # has_many :inventories, dependent: :destroy
end
