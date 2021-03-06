class User < ActiveRecord::Base
  attr_accessible :uid, :name, :key, :secret

  validates_presence_of :uid, :name, :key, :secret
  validates_uniqueness_of :uid

  has_many :problems, foreign_key: :creator_id
  has_many :answers, :dependent => :destroy
  has_many :answered_problems, through: :answers, source: :problem

  def self.create_with_omniauth(auth)
    create!(uid: auth["uid"], name: auth["info"]["nickname"], key: auth.credentials.token, secret: auth.credentials.secret)
  end

  def self.most_solved(limit = 10)
    User.all.select { | x | x.answers.count > 0 }.sort_by { | x | - x.answers.count }[0...limit]
  end

  def self.most_created(limit = 10)
    User.all.select { | x | x.problems.count > 0 }.sort_by { | x | - x.problems.count }[0...limit]
  end

  def to_s
    name
  end

  def accuracy
    if answers.count > 0
      answers.where(correct: true).count / answers.count.to_f * 100
    else
      0.0
    end
  end

  def solved?(problem)
    answered_problems.include? problem
  end

  def twitter_url
    "https://twitter.com/#!/#{name}"
  end
end
