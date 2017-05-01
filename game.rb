$window_width = 600
$window_height = 500
window_size $window_width+300, $window_height+100

$pi = Math.acos(-1)
$enemies = []
$towers = []
$money = 0
$score = 1900
$frame = 0
$stages = [
    [
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,0,0,0,0,0,0,0],
        [1,1,1,1,1,0,1,1,1,1,1,1],
        [1,1,1,1,1,0,1,1,1,1,1,1],
        [0,0,0,0,0,0,1,0,0,0,0,0],
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [0,0,1,1,1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,1,0,1,0,1,1],
        [1,1,1,0,0,0,1,0,0,0,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
    ],
    [
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,0,0,0,0,0,0,0],
        [1,1,1,1,1,0,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [0,0,0,0,0,0,1,0,0,0,0,0],
        [1,1,1,1,1,0,1,0,1,1,1,1],
        [1,1,1,1,1,0,1,0,1,1,1,1],
        [1,1,1,1,1,0,1,0,1,1,1,1],
        [1,1,1,1,1,0,0,0,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
    ],
    [
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,0,0,0,0,0,0,0],
        [1,1,0,0,0,0,1,1,1,1,1,1],
        [1,1,0,1,1,1,1,1,1,1,1,1],
        [0,0,0,1,0,0,1,0,0,0,0,0],
        [1,1,1,1,1,0,1,0,1,1,1,1],
        [1,1,1,1,1,0,1,0,1,1,1,1],
        [1,1,1,1,1,0,1,0,1,1,1,1],
        [1,1,1,1,1,0,0,0,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
    ]
]
$enemy_entrance = [[4,6],[4],[4]]
$level = 0
$game_over = false

class GameDetailSection
    def update
        draw_line($window_width,0,$window_width,$window_height,WHITE)
        draw_line(0,$window_height,$window_width,$window_height,WHITE)
        text("Money : #{$money}", x: $window_width + 50, y: 100)
        text("Score : #{$score}", x: $window_width + 50, y: 200)
    end
end

class Enemy
    attr_accessor :x, :y, :w, :h, :hp, :speed_x, :speed_y
    def initialize(x,y,w,h,hp,speed_x,speed_y,image)
        @hp = hp
        @x = x
        @y = y
        @w = w
        @h = h
        @speed_x = speed_x
        @speed_y = speed_y
        @image = image
    end

    def move
        @x += @speed_x
        @y += @speed_y

        if @speed_x > 0 && @x % 50 == 0
            if $stages[$level][@y/50][@x/50+1] == 1
                if $stages[$level][@y/50-1][@x/50] == 0
                    @speed_y = -@speed_x
                    @speed_x = 0
                else
                    @speed_y = @speed_x
                    @speed_x = 0
                end
            end
        end
        if @speed_x < 0 && @x % 50 == 0
            if $stages[$level][@y/50][@x/50-1] == 1
                if $stages[$level][@y/50-1][@x/50] == 0
                    @speed_y = @speed_x
                    @speed_x = 0
                else
                    @speed_y = -@speed_x
                    @speed_x = 0
                end
            end
        end
        if @speed_y > 0 && @y % 50 == 0
            if $stages[$level][@y/50+1][@x/50] == 1
                if $stages[$level][@y/50][@x/50-1] == 0
                    @speed_x = -@speed_y
                    @speed_y = 0
                else
                    @speed_x = @speed_y
                    @speed_y = 0
                end
            end
        end
        if @speed_y < 0 && @y % 50 == 0
            if $stages[$level][@y/50-1][@x/50] == 1
                if $stages[$level][@y/50][@x/50-1] == 0
                    @speed_x = @speed_y
                    @speed_y = 0
                else
                    @speed_x = -@speed_y
                    @speed_y = 0
                end
            end
        end
    end

    def draw
        put_image(@image,x:@x,y:@y,w:@w,h:@h)
    end

    def hit?(attack_object)
        return !(@x+@w < attack_object.x || @x > attack_object.x + attack_object.w || @y+@h < attack_object.y || @y > attack_object.y + attack_object.h)
    end

    def take_damage(damage)
        @hp -= damage
    end

    def update
        move
        draw
    end
end

class EnemyController
    HP = [50, 200, 500, 1000, 10000]
    SPEED = [1,1,2,2,5]
    def make_enemy
        entrance = $enemy_entrance[$level].sample
        $enemies.push(Enemy.new(0,entrance*50,50,50,HP[$level],SPEED[$level],0,"zombie.jpg"))
    end
    def update
        $enemies.each do |e|
            e.update
        end
        if $frame % 100 == 0
            make_enemy
        end
        $enemies.each.with_index do |e,i|
            if e.hp <= 0
                $enemies.delete_at(i)
                i -= 1
                $score += 100
                p $score
            end
        end
        $enemies.each do |e|
            if e.x >= $window_width-50
                $game_over = true
            end
        end
    end
end

class Tower
    attr_accessor :build_time, :attack_speed, :x, :y, :att_dir
    def initialize(x,y,w,h,att_dir,cost,damage,attack_speed,image)
        @x = x
        @y = y
        @w = w
        @h = h
        @att_dir = att_dir
        @cost = cost
        @image = image
        @damage = damage
        @attack_speed = attack_speed
        @attack_objects = []
        @build_time = $frame
    end

    def draw
        put_image(@image,x:@x,y:@y,w:@w,h:@h)
    end

    def update
        draw
        @attack_objects.each do |s|
            s.update
        end
        @attack_objects.delete_if{ |s| s.out_of_window? }
        @attack_objects.delete_if{ |s| s.hit? }
    end
end

class TowerController
     IMAGES = ["tower0.jpg","tower1.jpg","tower2.jpg","tower3.jpg","tower4.jpg"]
     COSTS = [100,200,300,1000,5000]
     def update
         $towers.each do |t|
             t.update
             if ($frame - t.build_time) % t.attack_speed == 0
                  t.attack
             end
         end
         IMAGES.each.with_index do |image,index|
             put_image(image, x: 100*index, y: $window_height, w: 100, h: 100)
         end
         COSTS.each.with_index do |cost,index|
             text("#{cost}",x: 100*index+25, y: $window_height+50,color: YELLOW)
         end
         if $selected != nil
             draw_line($selected*100,$window_height,$selected*100+100,$window_height,GREEN)
             draw_line($selected*100,$window_height,$selected*100,$window_height+100,GREEN)
             draw_line($selected*100,$window_height+100,$selected*100+100,$window_height+100,GREEN)
             draw_line($selected*100+100,$window_height,$selected*100+100,$window_height+100,GREEN)
         end
     end

     def rotate(x_pos,y_pos)
         x_index = x_pos / 50
         y_index = y_pos / 50
         $towers.each do |t|
             if x_index == t.x / 50 && y_index == t.y / 50
                 t.att_dir += $pi/2
                 if t.att_dir+0.00001 > 2*$pi
                     t.att_dir -= 2*$pi
                 end
             end
         end
     end

     def build_tower(x_pos,y_pos)
         x_index = x_pos / 50
         y_index = y_pos / 50
         if $selected == nil
             return
         elsif $money >= COSTS[$selected] && $stages[$level][y_index][x_index] == 1
             if $selected == 0
                 $towers.push(YowaiTower.new(x_index * 50,y_index * 50))
             elsif $selected == 1
                 $towers.push(KodaiTower.new(x_index * 50,y_index * 50))
             elsif $selected == 2
                 $towers.push(ChuseiTower.new(x_index * 50,y_index * 50))
             elsif $selected == 3
                 $towers.push(KindaiTower.new(x_index * 50,y_index * 50))
             elsif $selected == 4
                 $towers.push(GendaiTower.new(x_index * 50,y_index * 50))
             end
             $money -= COSTS[$selected]
         end
     end

     def select_tower(x_pos)
         $selected = x_pos / 100
     end
end

class YowaiTower < Tower
    WIDTH = 50
    HEIGHT = 50
    ATT_DIR = 0
    COST = 100
    DAMAGE = 10
    ATTACK_SPEED = 50
    IMAGE = "tower0.jpg"
    def initialize(x,y)
        super(x,y,WIDTH,HEIGHT,ATT_DIR,COST,DAMAGE,ATTACK_SPEED,IMAGE)
    end
    def attack
        if (@att_dir-$pi/2).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y,5,5,Math.cos(@att_dir)*2,-Math.sin(@att_dir)*2,@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x,@y+@h/2,5,5,Math.cos(@att_dir)*2,-Math.sin(@att_dir)*2,@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi*3/2).abs < 0.00000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y+@h,5,5,Math.cos(@att_dir)*2,-Math.sin(@att_dir)*2,@att_dir,@damage,"bullet.jpg")
        else
            attack_object = AttackObject.new(@x+@w,@y+@h/2,5,5,Math.cos(@att_dir)*2,-Math.sin(@att_dir)*2,@att_dir,@damage,"bullet.jpg")
        end
        
        @attack_objects.push(attack_object)
    end
end

class KodaiTower < Tower
    WIDTH = 50
    HEIGHT = 50
    ATT_DIR = 0
    COST = 200
    DAMAGE = 15
    ATTACK_SPEED = 40
    IMAGE = "tower1.jpg"
    def initialize(x,y)
        super(x,y,WIDTH,HEIGHT,ATT_DIR,COST,DAMAGE,ATTACK_SPEED,IMAGE)
    end
    def attack
        if (@att_dir-$pi/2).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi*3/2).abs < 0.00000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y+@h,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        else
            attack_object = AttackObject.new(@x+@w,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        end
        @attack_objects.push(attack_object)
    end
end

class ChuseiTower < Tower
    WIDTH = 50
    HEIGHT = 50
    ATT_DIR = 0
    COST = 300
    DAMAGE = 200
    ATTACK_SPEED = 100
    IMAGE = "tower2.jpg"
    def initialize(x,y)
        super(x,y,WIDTH,HEIGHT,ATT_DIR,COST,DAMAGE,ATTACK_SPEED,IMAGE)
    end
    def attack
        if (@att_dir-$pi/2).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi*3/2).abs < 0.00000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y+@h,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        else
            attack_object = AttackObject.new(@x+@w,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        end
        @attack_objects.push(attack_object)
    end
end

class KindaiTower < Tower
    WIDTH = 50
    HEIGHT = 50
    ATT_DIR = 0
    COST = 1000
    DAMAGE = 10
    ATTACK_SPEED = 10
    IMAGE = "tower3.jpg"
    def initialize(x,y)
        super(x,y,WIDTH,HEIGHT,ATT_DIR,COST,DAMAGE,ATTACK_SPEED,IMAGE)
    end
    def attack
        if (@att_dir-$pi/2).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi*3/2).abs < 0.00000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y+@h,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        else
            attack_object = AttackObject.new(@x+@w,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        end
        @attack_objects.push(attack_object)
    end
end

class GendaiTower < Tower
    WIDTH = 50
    HEIGHT = 50
    ATT_DIR = 0
    COST = 5000
    DAMAGE = 300
    ATTACK_SPEED = 50
    IMAGE = "tower4.jpg"
    def initialize(x,y)
        super(x,y,WIDTH,HEIGHT,ATT_DIR,COST,DAMAGE,ATTACK_SPEED,IMAGE)
    end
    def attack
        if (@att_dir-$pi/2).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi).abs < 0.00000000000000000001
            attack_object = AttackObject.new(@x,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        elsif (@att_dir-$pi*3/2).abs < 0.00000000000000001
            attack_object = AttackObject.new(@x+@w/2,@y+@h,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        else
            attack_object = AttackObject.new(@x+@w,@y+@h/2,5,5,Math.cos(@att_dir),-Math.sin(@att_dir),@att_dir,@damage,"bullet.jpg")
        end
        @attack_objects.push(attack_object)
    end
end

class AttackObject
    attr_accessor :x, :y, :w, :h, :speed_x, :speed_y, :att_dir, :damage
    def initialize(x,y,w,h,speed_x,speed_y,att_dir,damage,image)
        @x = x
        @y = y
        @w = w
        @h = h
        @speed_x = speed_x
        @speed_y = speed_y
        @att_dir = att_dir
        @damage = damage
        @image = image
    end

    def update
        move
        hit?
        draw
    end

    def move
        @x += @speed_x
        @y += @speed_y
    end

    def draw
        if (@att_dir-$pi/2).abs < 0.00000000000000000001
            put_image(@image,x:@x,y:@y,w:@w,h:@h,angle:-90)
        elsif (@att_dir-$pi).abs < 0.00000000000000000001
            put_image(@image,x:@x,y:@y,w:@w,h:@h,flip_horizontally: true)
        elsif (@att_dir-$pi*3/2).abs < 0.00000000000000001
            put_image(@image,x:@x,y:@y,w:@w,h:@h,angle: 90)
        else
            put_image(@image,x:@x,y:@y,w:@w,h:@h)
        end
    end

    def out_of_window?
        return @x > $window_width || @x < 0 || @y > $window_height || @y < 0
    end

    def hit?
        
        $enemies.each do |e|
            if e.hit?(self)
                e.take_damage(@damage)
                return true
            end
        end
        return false
    end
end

game_detail_section = GameDetailSection.new
enemy_controller = EnemyController.new
tower_controller = TowerController.new
yowai_tower = YowaiTower.new(0,0)
yowai_tower2 = YowaiTower.new(0,$window_height/2)

$selected = nil

mainloop do
    clear_window
    if !$game_over
        if $score % 2000 == 0 && $score != 0
            $level += 1
            $score = 0
            $towers = []
            $enemies = []
            $money = 0
            $game_over = true if $level == 3
        end
    game_detail_section.update

    $stages[$level].each.with_index do |e,y|
        e.each.with_index do |k,x|
            if k == 1
                put_image("wall.jpg",x: x*50, y: y*50, w: 50, h: 50)
            end
        end
    end

    if mousebutton_click?(1)
        x_pos = mouse_x
        y_pos = mouse_y
        if x_pos <= $window_width
            if $window_height < y_pos
                tower_controller.select_tower(x_pos)
            else
                tower_controller.build_tower(x_pos,y_pos)
            end
        end
    end

    if mousebutton_click?(3)
        x_pos = mouse_x
        y_pos = mouse_y
        if x_pos <= $window_width && y_pos <= $window_height
            tower_controller.rotate(x_pos,y_pos)
        end
    end

    enemy_controller.update

    tower_controller.update
    
    $money += $frame / 50
    $frame += 1
    else
        text("Game Over!!!!",x: $window_width/2, y: $window_height/2)
    end
end

