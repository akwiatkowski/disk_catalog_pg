class FullCache::Scanner::Periodic
  # in miliseconds, for easier testing
  INTERVAL_CACHE_SAVE_MS    = 60_000
  INTERVAL_STATS_PRESENT_MS = 10_000

  def initialize(
    @stats_presenter : StatsPresenter,
    @cache : Cache
  )
    @last_saved_at = Time.local
    @last_stats_presented_at = Time.local
  end

  def call
    present_stats
    save_cache
  end

  def present_stats
    present_stats! if present_stats?
  end

  def present_stats?
    (Time.local - @last_stats_presented_at).total_milliseconds.to_i >= INTERVAL_STATS_PRESENT_MS
  end

  def present_stats!
    @stats_presenter.call
    @last_stats_presented_at = Time.local
  end

  def save_cache
    save_cache! if save_cache?
  end

  def save_cache?
    (Time.local - @last_saved_at).total_milliseconds.to_i >= INTERVAL_CACHE_SAVE_MS
  end

  def save_cache!
    @cache.save
    @last_saved_at = Time.local
  end
end
