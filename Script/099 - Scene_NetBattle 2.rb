#==============================================================================
# ■ Scene_NetBattle (分割定义 1)
#------------------------------------------------------------------------------
# 　处理联机战斗画面的类。
#==============================================================================

class Scene_NetBattle < Scene_Battle
  #--------------------------------------------------------------------------
  # ● 普通攻击
  #--------------------------------------------------------------------------
  def common_attack(user,kf_id = 0,act_id = -1)
    # 设置目标
    t_arr = set_target(user)
    target,user_name,target_name,n_phase = t_arr[0],t_arr[1],t_arr[2],t_arr[3]
    # 获取攻击位置
    id = rand($data_system.hit_place.size)
    @atk_pos = $data_system.hit_place[id].deep_clone
    # 获取攻击招式
    if kf_id > 0
      atk_text = user.get_kf_id_action(kf_id,act_id)
    else
      atk_text = user.get_kf_action(0)
    end
    local_text = replace_text(atk_text.dup,user,user_name,target_name)
    send_text = replace_text(atk_text.dup,target,target_name,user_name)
    # 显示攻击文本
    show_text(local_text)
    send("text|" + send_text)
    # 应用普通攻击效果
    hit_para = user.attack_effect(target)
    damage,hit_type,hurt_num = hit_para[0],hit_para[1],hit_para[2]
    # 伤害为字符串，即未命中的情况
    if damage.is_a?(String)
      eva_result = damage.split(".")
      local_text = get_eva_text(eva_result[1].to_i,target,@atk_pos)
      send_text = get_eva_text(eva_result[1].to_i,user,@atk_pos)
      # 播放闪避音效
      $game_system.se_play($data_system.enemy_collapse_se)
      show_text(local_text)
      send("t&a|" + send_text + "|Miss")
    else # 造成伤害
      target.hp = [target.hp - damage, 0].max
      target.maxhp = [target.maxhp - hurt_num, 0].max
      local_text = get_hit_text(damage,hit_type,hurt_num,target)
      send_text = get_hit_text(damage,hit_type,hurt_num,user)
      # 应用吸血大法效果
      xi_lv = user.get_kf_level(56)
      user.hp = [user.hp+xi_lv*damage/100,user.maxhp].min
      @msg_window.auto_text(local_text)
      @msg_window.visible = true
      send("t&a|" + send_text + "|" + target.hp.to_s + "|" + target.maxhp.to_s)
      send_new_data
      # 播放击中动画
      target.animation_id = 1
      target.animation_hit = true
      @wait_count = 18
    end
  end
end