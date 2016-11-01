# 指定したボードの「未定」リストに存在するカードを
# 年月リストに振り分けるスクリプト
# 前提: 年月リストが存在すること

require 'trello'
require 'pry'
require 'dotenv'

include Trello
include Trello::Authorization


BOARD_ID = '58180298b2b62c4e881f2dea'
UNDEFINED_LIST_NAME = '未定'

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
OAuthPolicy.consumer_credential = OAuthCredential.new(ENV['APPLICATION_KEY'], ENV['APPLICATION_SECRET'])
OAuthPolicy.token = OAuthCredential.new(ENV['APPLICATION_TOKEN'], nil)

me = Trello::Member.find("me")

board = Board.find(BOARD_ID)


# 年月リストが足りない場合は作っておこう
# (1..12).each do |month|
#   list_name = Date.new(2015, month, 1).strftime('%Y/%m')
#   List.create(name: list_name, board_id: board.id)
# end

# {
#   '2016/01' => 'xxxxx',
#   '2016/02' => 'xxxxx',
#   ...
#   '2016/03' => 'xxxxx'
# }
card_hash = Hash[*board.lists.map { |l| [l.name, l.id] }.flatten]

unorganized_list = board.lists.find { |l| l.name == UNDEFINED_LIST_NAME }
unorganized_list.cards.each do |card|
  list_name = card.created_at.strftime('%Y/%m')
  list_id = card_hash[list_name]
  card.move_to_list(list_id)
end
