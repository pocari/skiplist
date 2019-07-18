# frozen_string_literal: true

class Node
  attr_accessor :x, :height, :next_nodes
  def initialize(x, height, next_nodes = [])
    @x = x
    @height = height
    @next_nodes = next_nodes
  end

  def inspect
    "(#{@x}, #{@height})"
  end
end

class SkipList
  # 適当にskiplistの最大のheightを決める
  # 50bit(= 高さは最大50)にしとく
  MAX_HEIGHT = 50
  RAND_MAX = 2**MAX_HEIGHT

  private_constant :MAX_HEIGHT, :RAND_MAX

  def initialize
    @length = 0
    @height = 0
    @sentinel = Node.new(nil, 0, [])
    @stack = Array.new(MAX_HEIGHT)
  end

  def find_pred_node(x)
    u = @sentinel
    r = @height
    while r >= 0
      u = u.next_nodes[r] while u.next_nodes[r] && u.next_nodes[r].x < x

      r -= 1
    end
    u
  end

  def add(x)
    uuu = @sentinel
    r = @height
    cmp = 0
    while r >= 0
      uuu = uuu.next_nodes[r] while uuu.next_nodes[r] && ((cmp = uuu.next_nodes[r].x <=> x) < 0)

      return false if uuu.next_nodes[r] && cmp.zero?

      @stack[r] = uuu
      r -= 1
    end
    new_node = Node.new(x, pick_height)
    while @height < new_node.height
      @height += 1
      @stack[@height] = @sentinel
    end

    0.upto(new_node.height) do |i|
      new_node.next_nodes[i] = @stack[i].next_nodes[i]
      @stack[i].next_nodes[i] = new_node
    end
    @length += 1
    true
  end

  def remove(x)
    removed = false
    uuu = @sentinel
    r = @height
    cmp = 0
    while r >= 0
      uuu = uuu.next_nodes[r] while uuu.next_nodes[r] && ((cmp = uuu.next_nodes[r].x <=> x) < 0)

      if uuu.next_nodes[r] && cmp.zero?
        removed = true
        uuu.next_nodes[r] = uuu.next_nodes[r].next_nodes[r]
        if uuu == sentitnel && !uuu.next_nodes[r]
          @height -= 1
        end
      end
      r -= 1
    end

    if removed
      @length -= 1
    end
    removed
  end

  def find(x)
    find_pred_node(x).next_nodes[0]&.x
  end

  def include?(x)
    find_pred_node(x).next_nodes[0]&.x == x
  end

  def pick_height
    z = rand(RAND_MAX)
    k = 0
    m = 1
    while (z & m) != 0
      k += 1
      m <<= 1
    end
    k
  end
end

sl = SkipList.new

sl.add(1)
sl.add(3)
sl.add(5)
(-1 .. 6).each do |i|
  puts format("%02d: find: %2s include?: %2s\n", i, sl.find(i), sl.include?(i))
end
