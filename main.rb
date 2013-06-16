require_relative "node.rb"

def adj(curr, goal, open, close, map)
  temp = Array.new
  deltas = [[-1, -1, -1, 0, 0, 1, 1, 1], [-1, 0, 1, -1, 1, -1, 0, 1]]

  # olası düğümler hesaplanır ve temp dizisine atılır.
  0.upto(deltas[0].length - 1) do |i|
    # olası düğüm yoksa yol yok demektir.
    if curr == nil or curr.g_x == nil or curr.g_y == nil
      p "Yol yok!!!"
      exit
    end
    adj_x = curr.g_x + deltas[0][i]
    adj_y = curr.g_y + deltas[1][i]

    if adj_y >= 0 and adj_y < map.length and adj_x >= 0 and adj_x < map[adj_y].length
      newnode = map[adj_y][adj_x]

      if newnode.g_cost >= 0 and !close.include?(newnode)
        temp << newnode
      end
    end
  end

  # olası düğümlerden maliyeti en düşük olan seçilir ve onunla yola devam edilir.
  temp.each do |node|
    if node.g_parent != nil
      node_copy = Node.new(node.g_x, node.g_y, node.g_cost)
      node_copy.s_parent(curr)

      if node_copy.value(goal) < node.value(goal)
        open.delete(node)
        open << node_copy
      end
    else
      node.s_parent(curr)
      open << node
    end
  end

  return open
end

# verilen x ve y boyutlarına göre rasgele bir labirent oluşturulması
def build_map(x_dim = 10, y_dim = 10)
  map = Array.new

  y_dim.times do |y|
    map << Array.new

    x_dim.times do |x|
      if (x == 0 and y == 0) or (x == x_dim - 1 and y == y_dim - 1) or rand > 0.2 # çok duvar olması için bu değer 0-1 aralığında arttırılır.
        map[y] << Node.new(x, y, 10)
      else
        map[y] << Node.new(x, y, -1)
      end
    end
  end

  return map
end

# planlanmış bir labirentin oluşturulması
def build_planned_map(plan)
  map = Array.new

  plan.length.times do |y|

    map << Array.new

    plan[y].length.times do |x|
      if plan[y][x] == "|"
        map[y] << Node.new(x, y, -1)
      else plan[y][x] == "."
        map[y] << Node.new(x, y, 10)
      end
    end
  end

  return map
end

# labirentin görsel şekile aktarılması
# x: Yol, S: Başlangıç, G: Hedef, |: Duvar
def print_map(map, start, goal, path = Array.new)
  out = ""

  map.each do |row|
    row.each do |cell|
      if cell == start
        out << "S "
      elsif cell == goal
        out << "G "
      elsif in_path?(path, cell)
        out << "X "
      else
        if cell.g_cost >= 0
          out << ". "
        else
          out << "| "
        end
      end
    end
    out << "\n"
  end
  return out
end

# doğru yolda mıyım? kontrolünü yapan fonksiyon
def in_path?(path, cell)
  path.each do |node|
    if cell.g_x == node.g_x and cell.g_y == node.g_y
      return true
    end
  end
  return false
end

# yol bulma fonksiyonunun hesaplanması
def find_path(start, goal, map)
  open = Array.new
  close = Array.new
  curr = start
  close << curr

  while curr != goal
    open = adj(curr, goal, open, close, map)

    lowest_index = 0

    1.upto(open.length - 1) do |i|
      if open[i].value(goal) < open[lowest_index].value(goal)
        lowest_index = i
      end
    end

    curr = open[lowest_index]
    close << open[lowest_index]
    open.delete_at(lowest_index)

     # puts curr
  end

  out = Array.new

  curr = close[close.length - 1]

  while curr != start
    out.insert(0, curr)
    curr = curr.g_parent
  end

  return out
end

# örnek plan
plan = [
  [".", "|", ".", ".", ".", ".", ".", ".", ".", "."],
  [".", "|", ".", ".", ".", ".", ".", ".", ".", "."],
  [".", "|", ".", "|", "|", "|", "|", "|", ".", "."],
  [".", "|", ".", ".", ".", ".", ".", "|", ".", "."],
  [".", "|", ".", ".", "|", "|", ".", "|", ".", "."],
  [".", "|", ".", ".", ".", "|", ".", "|", ".", "."],
  [".", "|", "|", "|", "|", "|", ".", "|", ".", "."],
  [".", "|", ".", ".", ".", ".", ".", "|", ".", "|"],
  [".", ".", ".", ".", ".", ".", ".", "|", ".", "."],
  [".", "|", ".", ".", ".", ".", ".", "|", "|", "."]
]

# rasgele labirentin inşa edilip map değişkenine atanması 
# map = build_map(15, 15)

# planlı labirentin inşa edilip map değişkenine atanması
map = build_planned_map(plan)

# yol bulma fonksiyonun path değişkenine atanması
path = find_path(map[0][0], map[9][9], map)

# birim zamandaki x in yer değişimi
path.size.times do |i|
  # puts clean_screen
  puts "\e[H\e[2J"
  puts print_map(map, map[0][0], map[9][9], path[0..i])
  sleep 0.5
end
