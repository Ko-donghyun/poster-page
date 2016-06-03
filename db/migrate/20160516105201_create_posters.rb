class CreatePosters < ActiveRecord::Migration
  def change
    create_table :posters do |t|
      
      t.string :movie_title # 영화 제목
      t.string :movie_same_title #영화 띄워쓰기 제외한 제목
      t.string :image_url   # 포스터 이미지
      # t.string :available   # 포스터 요청
      t.integer :user_id    # 업로드한 유저
      
      t.timestamps null: false
    end
  end
end
