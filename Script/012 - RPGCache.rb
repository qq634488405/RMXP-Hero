#==============================================================================
# ■ RPG::Cache
#------------------------------------------------------------------------------
# 　定义Cache模块
#==============================================================================

module RPG
  module Cache
    #--------------------------------------------------------------------------
    # ● 加载Bitmap，根据色彩模式选择不同目录
    #--------------------------------------------------------------------------
    def self.load_bitmap(folder_name, filename, hue = 0)
      folder_name += "Gray/" if $color_mode != 0
      path = folder_name + filename
      if not @cache.include?(path) or @cache[path].disposed?
        if filename != ""
          @cache[path] = Bitmap.new(path)
        else
          @cache[path] = Bitmap.new(32, 32)
        end
      end
      if hue == 0
        @cache[path]
      else
        key = [path, hue]
        if not @cache.include?(key) or @cache[key].disposed?
          @cache[key] = @cache[path].clone
          @cache[key].hue_change(hue)
        end
        @cache[key]
      end
    end
  end
end