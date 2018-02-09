#! /usr/bin/ruby

# ���񐶐�
class Array
  def perms
    return [[]] if empty?
    uniq.inject([]) do |rs, h|
      tmp = self.dup
      tmp.delete_at(index(h))
      rs + tmp.perms.map {|t| [h] + t }
    end
  end
  def total
    self.inject(0){|t,a| t += a}
  end
end

# a : [[1,1,1], [1,1,1], [1,1,1], [1,1,1], [2]]
def ptn(a)
  if a.size == 1 then
    return [a]
  end
  ret = Array.new
  # �d�Ȃ�Ȃ��p�^�[��
  ret += a.perms
  # �d�Ȃ�p�^�[��
  h1 = Hash.new
  for i in 0..a.size-1
    for j in i+1..a.size-1
      key = [a[i], 0, a[j]].to_s
      if !h1.key?(key) then
        h1.store(key, nil)
        h2 = Hash.new
        # a[i]��a[j]��͈͂����炵�Ȃ���d�˂�
        for k in 0..a[i].size+a[j].size
          t = [0]*a[j].size + a[i] + [0]*a[j].size
          for m in 0..a[j].size-1
            t[k+m] += a[j][m]
          end
          # �]����0����菜��
          t.delete(0)
          # 4���傫���l���Ȃ����`�F�b�N
          next if t.any? {|v| v > 4}
          # 9��蒷���Ȃ����`�F�b�N
          next if t.size >9
          # �d���`�F�b�N
          if !h2.key?(t.to_s) then
            h2.store(t.to_s, nil)
            # �c��
            t2 = a.dup
            t2.delete_at(i)
            t2.delete_at(j-1)
            # �ċA�Ăяo��
            ret += ptn([t]+t2)
          end
        end
      end
    end
  end
  return ret
end

# �L�[�l���v�Z
def calc_key(a)
  ret = 0
  len = -1
  for b in a
    for i in b
      len += 1
      case i
      when 2 then
        ret |= 0b11 << len
        len += 2
      when 3 then
        ret |= 0b1111 << len
        len += 4
      when 4 then
        ret |= 0b111111 << len
        len += 6
      end
    end
    ret |= 0b1 << len
    len += 1
  end
  return ret
end

# a : [[1,1,1], [1,1,1], [1,1,1], [1,1,1], [2]]
# ret
# ����
#   3bit  0: ���q�̐�(0�`4)
#   3bit  3: ���q�̐�(0�`4)
#   4bit  6: ���̈ʒu(1�`13)
#   4bit 10: �ʎq�̈ʒu�P(0�`13)
#   4bit 14: �ʎq�̈ʒu�Q(0�`13)
#   4bit 18: �ʎq�̈ʒu�R(0�`13)
#   4bit 22: �ʎq�̈ʒu�S(0�`13)
#   1bit 26: ���Ύq�t���O
#   1bit 27: ��@�󓕃t���O
#   1bit 28: ��C�ʊуt���O
#   1bit 29: ��u���t���O
#   1bit 30: ��u���t���O
def find_hai_pos(a)
  ret_array = Array.new
  p_atama = 0
  for i in 0..a.size-1
    for j in 0..a[i].size-1
      # ����T��
      if a[i][j] >= 2 then
        # ���q�A���q�̗D�揇�ʓ���ւ�
        for kotsu_shuntus in 0..1
          t = Marshal.load(Marshal.dump(a))
          t[i][j] -= 2

          p = 0
          p_kotsu = Array.new
          p_shuntsu = Array.new
          for k in 0..t.size-1
            for m in 0..t[k].size-1
              if kotsu_shuntus == 0 then
                # ���q���Ɏ��o��
                # ���q
                if t[k][m] >= 3 then
                  t[k][m] -= 3
                  p_kotsu.push(p)
                end
                # ���q
                while t[k].size - m >= 3 &&
                  t[k][m] >= 1 &&
                  t[k][m+1] >= 1 &&
                  t[k][m+2] >= 1 do
                    t[k][m] -= 1
                    t[k][m+1] -= 1
                    t[k][m+2] -= 1
                    p_shuntsu.push(p)
                end
              else
                # ���q���Ɏ��o��
                # ���q
                while t[k].size - m >= 3 &&
                  t[k][m] >= 1 &&
                  t[k][m+1] >= 1 &&
                  t[k][m+2] >= 1 do
                    t[k][m] -= 1
                    t[k][m+1] -= 1
                    t[k][m+2] -= 1
                    p_shuntsu.push(p)
                end
                # ���q
                if t[k][m] >= 3 then
                  t[k][m] -= 3
                  p_kotsu.push(p)
                end
              end
              p += 1
            end
          end
          
          # �オ��̌`���H
          if t.flatten.all? {|x| x==0 } then
            # �l�����߂�
            ret = p_kotsu.size + (p_shuntsu.size << 3) + (p_atama << 6)
            len = 10
            for x in p_kotsu
              ret |= x << len
              len += 4
            end
            for x in p_shuntsu
              ret |= x << len
              len += 4
            end
            if a.size == 1 then
              # ��@�󓕃t���O
              if a == [[4,1,1,1,1,1,1,1,3]] ||
                a == [[3,2,1,1,1,1,1,1,3]] ||
                a == [[3,1,2,1,1,1,1,1,3]] ||
                a == [[3,1,1,2,1,1,1,1,3]] ||
                a == [[3,1,1,1,2,1,1,1,3]] ||
                a == [[3,1,1,1,1,2,1,1,3]] ||
                a == [[3,1,1,1,1,1,2,1,3]] ||
                a == [[3,1,1,1,1,1,1,2,3]] ||
                a == [[3,1,1,1,1,1,1,1,4]] then
                ret |= 1 << 27
              end
            end
            # ��C�ʊ�
            if a.size <= 3 && p_shuntsu.size >= 3 then
              p_ikki = 0
              for b in a
                if b.size == 9 then
                  b_ikki1 = false
                  b_ikki2 = false
                  b_ikki3 = false
                  for x_ikki in p_shuntsu
                    b_ikki1 |= (x_ikki == p_ikki)
                    b_ikki2 |= (x_ikki == p_ikki+3)
                    b_ikki3 |= (x_ikki == p_ikki+6)
                  end
                  if b_ikki1 && b_ikki2 && b_ikki3 then
                    ret |= 1 << 28
                  end
                end
                p_ikki += b.size
              end
            end
            # ��u��
            if p_shuntsu.size == 4 &&
              p_shuntsu[0] == p_shuntsu[1] &&
              p_shuntsu[2] == p_shuntsu[3] then
              ret |= 1 << 29
            elsif p_shuntsu.size >= 2 &&  p_kotsu.size + p_shuntsu.size == 4 then
              # ��u��
              if p_shuntsu.size - p_shuntsu.uniq.size >= 1 then
                ret |= 1 << 30
              end
            end
            ret_array.push(ret)
          end
        end
      end
      p_atama += 1
    end
  end
  if ret_array.size > 0 then
    ret_array.uniq!
    return ret_array.inject("0x"+ret_array.shift.to_s(16)){|t,a| t += ","+"0x"+a.to_s(16)}
  end
  t = a.flatten
  # ���Ύq����
  if t.total == 14 && t.all? {|x| x==2} then
    return "0x"+(1 << 26).to_s(16)
  end
end

chitoi = ptn([[2],[2],[2],[2],[2],[2],[2]])
chitoi.delete_if{|x|
  t = x.flatten
  t.any?{|y| y != 2}
}

(ptn([[1,1,1],[1,1,1],[1,1,1],[1,1,1],[2]]) +
 ptn([[1,1,1],[1,1,1],[1,1,1],[3],[2]]) +
 ptn([[1,1,1],[1,1,1],[3],[3],[2]]) +
 ptn([[1,1,1],[3],[3],[3],[2]]) +
 ptn([[3],[3],[3],[3],[2]]) +
 chitoi).uniq.each do |x|
  printf("tbl.put(0x%X, new int[] {%s});\n", calc_key(x), find_hai_pos(x))
end

(ptn([[1,1,1],[1,1,1],[1,1,1],[2]]) +
 ptn([[1,1,1],[1,1,1],[3],[2]]) +
 ptn([[1,1,1],[3],[3],[2]]) +
 ptn([[3],[3],[3],[2]])).uniq.each do |x|
  printf("tbl.put(0x%X, new int[] {%s});\n", calc_key(x), find_hai_pos(x))
end

(ptn([[1,1,1],[1,1,1],[2]]) +
 ptn([[1,1,1],[3],[2]]) +
 ptn([[3],[3],[2]])).uniq.each do |x|
  printf("tbl.put(0x%X, new int[] {%s});\n", calc_key(x), find_hai_pos(x))
end

(ptn([[1,1,1],[2]]) +
 ptn([[3],[2]])).uniq.each do |x|
  printf("tbl.put(0x%X, new int[] {%s});\n", calc_key(x), find_hai_pos(x))
end

(ptn([[2]])).uniq.each do |x|
  printf("tbl.put(0x%X, new int[] {%s});\n", calc_key(x), find_hai_pos(x))
end
