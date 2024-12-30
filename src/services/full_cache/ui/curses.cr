require "crt"

require "../models/unit"
require "../scanner/stats_storage"

class FullCache::Ui::Curses
  HEIGHT_BORDER = 2*1
  HEIGHT_TITLE  = 1
  HEIGTH_CONST  = HEIGHT_BORDER + HEIGHT_TITLE

  LOGS_MAX_LINES = 20

  REFRESH_INTERVAL_MS_LOGS      = 200
  REFRESH_INTERVAL_MS_LAST_FILE = 200
  REFRESH_INTERVAL_MS_STATS     = 200

  def initialize
    Crt.init

    @max_x = Crt.x
    @max_y = Crt.y

    @stats_window = Crt::Window.new(
      @max_y - LOGS_MAX_LINES - HEIGTH_CONST,
      @max_x // 2,
      0,
      0
    )
    @stats_window.border

    @logs_window = Crt::Window.new(
      LOGS_MAX_LINES + HEIGTH_CONST,
      @max_x,
      @max_y - LOGS_MAX_LINES - HEIGTH_CONST,
      0
    )
    @logs_window.border
    @logs_window.start_color

    @last_file_window = Crt::Window.new(
      @max_y - LOGS_MAX_LINES - HEIGTH_CONST,
      @max_x // 2,
      0,
      @max_x // 2
    )
    @last_file_window.border

    @logs_buffer = Array(String).new

    @last_refreshed_logs = Time.unix(0)
    @last_refreshed_last_file = Time.unix(0)
    @last_refreshed_stats = Time.unix(0)

    refresh
  end

  def finish
    Crt.done
  end

  def refresh
    refresh_logs
    refresh_stats
    refresh_last_file_details
  end

  def refresh_logs
    @logs_window.clear
    @logs_window.border
    @logs_window.print(
      1,
      1,
      "Logs:"
    )
    @logs_buffer.each_with_index do |string, index|
      @logs_window.print(
        1 + index,
        1,
        string
      )
    end

    @logs_window.refresh

    @last_refreshed_logs = Time.local
  end

  def refresh_last_file_details_and_stats(
    stats_storage : Scanner::StatsStorage?,
    file_path : String,
    unit : Models::Unit
  )
    refresh_stats(
      stats_storage: stats_storage
    )
    refresh_last_file_details(
      file_path: file_path,
      unit: unit
    )
  end

  def refresh_stats(
    stats_storage : Scanner::StatsStorage? = nil
  )
    return unless (Time.local - @last_refreshed_stats).total_milliseconds >= REFRESH_INTERVAL_MS_STATS

    @stats_window.clear
    @stats_window.border

    @stats_window.print(
      1,
      1,
      "Stats:"
    )

    if stats_storage
      y = 3
      stats_storage.not_nil!.to_h.each do |key, value|
        @stats_window.print(
          y,
          1,
          "#{key} = #{value}"
        )
        y += 1
      end

      y += 1
      stats_storage.not_nil!.to_h_missed_keys.each do |key, value|
        @stats_window.print(
          y,
          1,
          "#{key} = #{value}"
        )
        y += 1
      end

      y += 1
      stats_storage.not_nil!.to_h_additional.each do |key, value|
        @stats_window.print(
          y,
          1,
          "#{key} = #{value}"
        )
        y += 1
      end
    end

    @stats_window.refresh

    @last_refreshed_stats = Time.local
  end

  def refresh_last_file_details(
    file_path : String? = nil,
    unit : Models::Unit? = nil
  )
    return unless (Time.local - @last_refreshed_last_file).total_milliseconds >= REFRESH_INTERVAL_MS_LAST_FILE

    @last_file_window.clear
    @last_file_window.border

    @last_file_window.print(
      1,
      1,
      "Last file:"
    )

    if file_path
      y = 3

      truncated_path = file_path[/.{1,70}$/]
      @last_file_window.print(
        y,
        1,
        "path = #{truncated_path}"
      )
    end

    if unit
      y = 4
      unit.not_nil!.to_h.each do |key, value|
        @last_file_window.print(
          y,
          1,
          "#{key} = #{value}"
        )

        y += 1
      end
    end

    @last_file_window.refresh

    @last_refreshed_last_file = Time.local
  end

  def append_log_line(string : String, force : Bool = false)
    @logs_buffer << string
    @logs_buffer.shift if @logs_buffer.size > LOGS_MAX_LINES

    should_render = force || (Time.local - @last_refreshed_logs).total_milliseconds >= REFRESH_INTERVAL_MS_LOGS

    refresh_logs if should_render
  end
end
