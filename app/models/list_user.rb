class ListUser < ApplicationRecord
  belongs_to :user
  belongs_to :list

  enum role: { owner: 'owner', collaborator: 'collaborator' }
end
