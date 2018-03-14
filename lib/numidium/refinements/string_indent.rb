module Numidium
  module StringIndent
    refine String do
      def indent(level=1, with="  ")
        split("\n").map{|line| with*level+line}.join("\n")
      end
    end

    refine Array do
      def indent(level=1, with="  ")
        self.map{|line| with*level+line}
      end
    end
  end
end
