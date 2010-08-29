require 'pixel'

class Player < Pixel
  trait :timer
  attr_reader :energy, :max_energy

  MIN_CAPTURE_DISTANCE = SIZE * 6

  MAX_HEALTH, MAX_ENERGY = 1000, 1000
  ENERGY_HEAL = 5
  ENERGY_CONTROL = 5

  def initialize(options = {})
    options = {:color => Color::BLUE.dup}.merge! options
    super(MAX_HEALTH, options)

    add_inputs(
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    @max_energy = @energy = MAX_ENERGY

    @speed = 2
    @damage = 5

    @hurt = Sample["hurt_player.wav"]
    @control_on = Sample["control_on.wav"]
    @control_off = Sample["control_off.wav"]
    @control_fail = Sample["control_fail.wav"]
    @death = Sample["death.wav"]

    lose_control
  end

  def move_controlled
    if holding_any? :left, :a
      if holding_any? :up, :w
        @controlled.move(-0.707, -0.707)
      elsif holding_any? :down, :s
        @controlled.move(-0.707, 0.707)
      else
        @controlled.move(-1, 0)
      end
    elsif holding_any? :right, :d
      if holding_any? :up, :w
        @controlled.move(0.707, -0.707)
      elsif holding_any? :down, :s
        @controlled.move(0.707, 0.707)
      else
        @controlled.move(1, 0)
      end
    elsif holding_any? :up, :w
      @controlled.move(0, -1)
    elsif holding_any? :down, :s
      @controlled.move(0, 1)
    else
      @controlled.move(0, 0)
    end
  end

  def update
    super

    move_controlled

    if controlling?
      self.energy -= ENERGY_CONTROL
    else
      self.energy += ENERGY_HEAL
    end
  end

  def draw
    super
    if controlling?
      $window.draw_line(self.x, self.y, self.color, @controlled.x, @controlled.y, @controlled.color, ZOrder::CONTROL)
    end
  end

  def energy=(value)
    @energy = [[0, value].max, max_energy].min
    if controlling?
      lose_control if @energy == 0
    else
      color.blue = (((@energy * 155.0) / max_energy) + 100).to_i unless controlling?
      color.red = color.green = 255 - color.blue
    end
  end

  def die
    @death.play(0.5)
    super
  end

  def controlling?
    @controlled != self
  end

  def lose_control
    @controlled ||= self
    if @controlled != self
      @controlled.uncontrol
      @control_off.play(0.5)
    end
    @controlled = self
    color.red = color.green = 0
    self.energy = energy # Get colour back.
  end

  def gain_control
    nearest_distance = 99999999
    nearest_enemy = nil
    Enemy.all.each do |enemy|
      distance = distance(self.x, self.y, enemy.x, enemy.y)
      if distance < MIN_CAPTURE_DISTANCE and distance < nearest_distance
        nearest_distance = distance
        nearest_enemy = enemy
      end
    end

    if nearest_enemy
      @controlled = nearest_enemy
      @controlled.control(self)
      color.blue = color.red = color.green = 255 # Blueness shoots over to the enemy.
      @control_on.play(0.5)
    else
      @control_fail.play(0.5)
    end
  end

  def safe_distance
    SIZE * 4
  end
end