module StringIndent
  refine String do
    def indent(level, with="  ")
      split("\n").map{|line| with*level+line}.join("\n")
    end
  end
end
