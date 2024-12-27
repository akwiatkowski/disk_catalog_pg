require "colorize"

class Lg
  # https://crystal-lang.org/api/master/Colorize.html
  COLOR_ERROR     = :red
  COLOR_INFO      = :green
  COLOR_DEBUG     = :light_gray
  COLOR_THRIVIAL  = :light_gray
  COLOR_IMPORTANT = :light_cyan

  COLOR_PLACE = :light_yellow
  COLOR_TIME  = :cyan
  COLOR_PATH  = :light_magenta

  LEVELS_ENABLED = {
    "thrivial"  => false,
    "debug"     => false,
    "error"     => true,
    "info"      => true,
    "important" => true,
  }

  LEVELS_CHARS = {
    "error"     => "E".colorize.fore(COLOR_ERROR),
    "info"      => "I".colorize.fore(COLOR_INFO),
    "important" => "!".colorize.fore(COLOR_IMPORTANT),
    "debug"     => "D".colorize.fore(COLOR_DEBUG),
    "thrivial"  => ".".colorize.fore(COLOR_THRIVIAL),
  }

  # TODO:
  # add ability to enable/disable various levels
  # refactor to make more DRY

  def self.error(
    place,
    message : String,
    path : (String | Path | Nil) = nil
  )
    log(
      level: "error",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_ERROR).to_s
    )
  end

  # ## info

  def self.info(
    place,
    message : String,
    path : (String | Path | Nil) = nil
  )
    log(
      level: "info",
      place: place,
      path: path,
      message: message
    )
  end

  def self.info(
    place,
    message : String,
    path : (String | Path | Nil) = nil,
    &
  )
    log(
      level: "info",
      place: place,
      path: path,
      message: message
    ) do
      yield
    end
  end

  # ## important

  def self.important(
    place,
    message : String,
    path : (String | Path | Nil) = nil
  )
    log(
      level: "important",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_IMPORTANT).to_s
    )
  end

  def self.important(
    place,
    message : String,
    path : (String | Path | Nil) = nil,
    &
  )
    log(
      level: "important",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_IMPORTANT).to_s
    ) do
      yield
    end
  end

  # ## debug

  def self.debug(
    place,
    message : String,
    path : (String | Path | Nil) = nil
  )
    log(
      level: "debug",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_DEBUG).to_s
    )
  end

  def self.debug(
    place,
    message : String,
    path : (String | Path | Nil) = nil,
    &
  )
    log(
      level: "debug",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_DEBUG).to_s
    ) do
      yield
    end
  end

  # ## thrivial

  def self.thrivial(
    place,
    message : String,
    path : (String | Path | Nil) = nil
  )
    log(
      level: "thrivial",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_THRIVIAL).to_s
    )
  end

  def self.thrivial(
    place,
    message : String,
    path : (String | Path | Nil) = nil,
    &
  )
    log(
      level: "thrivial",
      place: place,
      path: path,
      message: message.colorize.fore(COLOR_THRIVIAL).to_s
    ) do
      yield
    end
  end

  # ## log

  def self.render_string(
    level,
    place,
    message,
    path
  )
    return "#{time_string} #{LEVELS_CHARS[level]}:#{convert_place(place)} - #{message} #{path.to_s.colorize.fore(COLOR_PATH)}".strip.gsub(/\s{2,10}/, "")
  end

  def self.enabled?(level)
    return LEVELS_ENABLED[level]
  end

  def self.log(
    level,
    place,
    path : (String | Path | Nil),
    message : String
  )
    string = render_string(
      level: level,
      place: place,
      message: message,
      path: path
    )
    puts string if enabled?(level)
  end

  def self.log(
    level,
    place,
    path : (String | Path | Nil),
    message : String,
    &
  )
    string = render_string(
      level: level,
      place: place,
      message: message,
      path: path
    )
    puts string if enabled?(level)

    t = Time.local
    yield
    ts = (Time.local - t).total_microseconds

    puts "#{string} (#{convert_us_to_readable(ts)})" if enabled?(level)
  end

  def self.convert_place(place)
    place.to_s.split(/::/).last.colorize.fore(COLOR_PLACE)
  end

  def self.convert_us_to_readable(us_span)
    if us_span < 10_000
      # 10ms
      span_string = "#{us_span.to_i}us"
    elsif us_span < 10_000_000
      # 10s
      span_string = "#{(us_span / 1000.0).to_i}ms"
    elsif us_span < (600 * 1_000_000)
      span_string = "#{(us_span / 1000_000.0).to_i}s"
    else
      span_string = "#{(us_span / 1000_000.0).to_i / 60.0}min"
    end

    return span_string.colorize.fore(COLOR_TIME)
  end

  def self.time_string
    # return Time.local.to_s("%Y-%m-%d %H:%M:%S.%3N")
    return Time.local.to_s("%H:%M:%S.%3N")
  end
end
