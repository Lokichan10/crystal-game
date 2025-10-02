
require "random"

class Character
  property name : String
  property hp : Int32
  property max_hp : Int32
  property attack : Int32
  property defense : Int32
  property level : Int32
  property exp : Int32
  property inventory : Array(String)

  def initialize(@name : String, @hp : Int32, @attack : Int32, @defense : Int32)
    @max_hp = @hp
    @level = 1
    @exp = 0
    @inventory = [] of String
  end

  def take_damage(amount : Int32)
    damage = amount - @defense
    damage = 0 if damage < 0
    @hp -= damage
    damage
  end

  def attack_target(target : Character)
    damage = @attack + Random.rand(0..5)
    dealt = target.take_damage(damage)
    puts "#{@name} attacks #{target.name} for #{dealt} damage!"
  end

  def heal(amount : Int32)
    @hp += amount
    @hp = @max_hp if @hp > @max_hp
    puts "#{@name} heals for #{amount} HP!"
  end

  def gain_exp(amount : Int32)
    @exp += amount
    puts "#{@name} gains #{amount} EXP!"
    while @exp >= 50
      level_up
      @exp -= 50
    end
  end

  private def level_up
    @level += 1
    @max_hp += 10
    @attack += 2
    @defense += 1
    @hp = @max_hp
    puts "#{@name} leveled up! Now level #{@level}!"
  end
end

class Monster
  property name : String
  property hp : Int32
  property max_hp : Int32
  property attack : Int32
  property defense : Int32
  property exp_reward : Int32

  def initialize(@name : String, @hp : Int32, @attack : Int32, @defense : Int32, @exp_reward : Int32)
    @max_hp = @hp
  end

  def take_damage(amount : Int32)
    damage = amount - @defense
    damage = 0 if damage < 0
    @hp -= damage
    damage
  end

  def attack_target(target : Character)
    damage = @attack + Random.rand(0..3)
    dealt = target.take_damage(damage)
    puts "#{@name} attacks #{target.name} for #{dealt} damage!"
  end
end

# ------------------------------
# Логика боя
# ------------------------------

def battle(player : Character, enemy : Monster)
  puts "\nA wild #{enemy.name} appears!"
  while player.hp > 0 && enemy.hp > 0
    puts "\n#{player.name} HP: #{player.hp}/#{player.max_hp} | #{enemy.name} HP: #{enemy.hp}/#{enemy.max_hp}"
    puts "Choose action: 1) Attack 2) Heal 3) Inventory"
    print "> "
    action = gets.try(&.chomp) || "1"

    case action
    when "1"
      player.attack_target(enemy)
    when "2"
      heal_amount = Random.rand(10..20)
      player.heal(heal_amount)
    when "3"
      if player.inventory.size > 0
        puts "Inventory: #{player.inventory.join(", ")}"
      else
        puts "Inventory is empty."
      end
    else
      puts "Invalid action, you lose your turn!"
    end

    break if enemy.hp <= 0
    enemy.attack_target(player)
  end

  if player.hp > 0
    puts "\n#{player.name} defeated #{enemy.name}!"
    player.gain_exp(enemy.exp_reward)
    loot_chance(player)
  else
    puts "\n#{player.name} was defeated by #{enemy.name}..."
  end
end

# ------------------------------
# Лут и случайные события
# ------------------------------

def loot_chance(player : Character)
  loot_roll = Random.rand(1..100)
  if loot_roll <= 50
    item = ["Potion", "Gold Coin", "Elixir", "Magic Scroll"].sample
    player.inventory << item
    puts "You found a #{item}!"
  else
    puts "No loot this time."
  end
end

def random_event(player : Character)
  roll = Random.rand(1..100)
  case roll
  when 1..30
    damage = Random.rand(5..15)
    player.hp -= damage
    puts "\nRandom trap! #{player.name} takes #{damage} damage."
  when 31..60
    heal_amount = Random.rand(5..15)
    player.heal(heal_amount)
  when 61..80
    item = ["Potion", "Magic Stone", "Scroll"].sample
    player.inventory << item
    puts "\nYou found a #{item} lying on the ground!"
  when 81..100
    puts "\nNothing happens..."
  end
end

# ------------------------------
# Генерация монстров
# ------------------------------

def generate_monster(level : Int32)
  names = ["Goblin", "Orc", "Troll", "Wolf", "Skeleton"]
  name = names.sample
  hp = 20 + level * 5
  attack = 5 + level * 2
  defense = 1 + level
  exp_reward = 20 + level * 5
  Monster.new(name, hp, attack, defense, exp_reward)
end

# ------------------------------
# Главная игра
# ------------------------------

puts "Welcome to Crystal RPG!"
print "Enter your character name: "
player_name = gets.try(&.chomp) || "Hero"
player = Character.new(player_name, 100, 10, 5)

loop do
  puts "\nChoose an action: 1) Explore 2) Show Stats 3) Quit"
  print "> "
  choice = gets.try(&.chomp) || "1"

  case choice
  when "1"
    puts "\nExploring..."
    random_event(player)
    monster = generate_monster(player.level)
    battle(player, monster)
    if player.hp <= 0
      puts "\nGame Over!"
      break
    end
  when "2"
    puts "\n#{player.name} Stats:"
    puts "Level: #{player.level} | HP: #{player.hp}/#{player.max_hp} | Attack: #{player.attack} | Defense: #{player.defense} | EXP: #{player.exp}"
    puts "Inventory: #{player.inventory.join(", ")}"
  when "3"
    puts "Thanks for playing!"
    break
  else
    puts "Invalid choice."
  end
end
