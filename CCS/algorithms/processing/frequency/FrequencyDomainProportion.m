function proportion = FrequencyDomainProportion(data, fs, f_low, f_high)
% FrequencyDomainProportion Compute proportion of spectral power within a band
%   proportion = FrequencyDomainProportion(data, fs, f_low, f_high)
%   computes the proportion of power spectral density (PSD) contained in the
%   frequency band [f_low, f_high] relative to the total power in [0, fs/2].
%
%   Inputs:
%     - data   : Numeric vector or matrix (N x M). Each column is a channel.
%     - fs     : Sampling frequency (Hz), scalar > 0
%     - f_low  : Lower bound of band (Hz), scalar >= 0
%     - f_high : Upper bound of band (Hz), scalar > f_low
%
%   Output:
%     - proportion : Scalar if data is a vector, otherwise 1 x M vector with
%                    band power proportion per column.
%
%   Notes:
%     - The function removes the mean of the data to reduce DC dominance.
%     - PSD is estimated using Welch's method if available; otherwise a
%       one-sided periodogram via FFT is used.

  % Validate inputs
  if nargin < 4
    error('FrequencyDomainProportion requires inputs: data, fs, f_low, f_high');
  end
  if ~isnumeric(data) || isempty(data)
    error('data must be a non-empty numeric vector or matrix.');
  end
  if ~isscalar(fs) || ~isfinite(fs) || fs <= 0
    error('fs must be a positive finite scalar.');
  end
  if ~isscalar(f_low) || ~isscalar(f_high) || any(~isfinite([f_low, f_high]))
    error('f_low and f_high must be finite scalars.');
  end

  % Clamp the requested band to [0, fs/2]
  nyquist = fs / 2;
  band_low = max(0, min(f_low, nyquist));
  band_high = max(0, min(f_high, nyquist));
  if band_high <= band_low
    % Degenerate band -> zero proportion
    proportion = 0;
    if ~isvector(data)
      proportion = zeros(1, size(data, 2));
    end
    return;
  end

  % Ensure data is column-oriented: N x M
  if isvector(data)
    data = data(:);
  end
  [num_samples, num_channels] = size(data);

  % Prepare output
  proportion = nan(1, num_channels);

  % Choose Welch parameters (if used)
  % Segment length: min(4096, max(128, floor(N/4)))
  seglen_default = min(4096, max(128, floor(num_samples / 4)));
  if seglen_default < 32
    seglen_default = min(num_samples, 32);
  end
  overlap_default = floor(seglen_default / 2);

  use_welch = exist('pwelch', 'file') == 2; %#ok<EXIST>

  for channel_index = 1:num_channels
    x = double(data(:, channel_index));

    % Handle NaNs: replace with column mean (excluding NaNs). If all NaN -> NaN proportion.
    if any(~isfinite(x))
      finite_mask = isfinite(x);
      if ~any(finite_mask)
        proportion(channel_index) = NaN;
        continue;
      end
      mean_val = mean(x(finite_mask));
      x(~finite_mask) = mean_val;
    end

    % Demean to mitigate DC
    x = x - mean(x);

    % Skip if too short
    if numel(x) < 4
      proportion(channel_index) = NaN;
      continue;
    end

    if use_welch
      % Welch PSD estimate
      seglen = min(seglen_default, numel(x));
      if seglen < 16
        seglen = min(numel(x), 16);
      end
      try
        win = hamming(seglen, 'periodic');
      catch
        win = hamming(seglen);
      end
      noverlap = min(overlap_default, max(0, seglen - 1));
      nfft = max(256, 2^nextpow2(seglen));
      [Pxx, F] = pwelch(x, win, noverlap, nfft, fs, 'onesided');
    else
      % Periodogram via FFT
      N = numel(x);
      try
        win = hann(N, 'periodic');
      catch
        try
          win = hann(N);
        catch
          win = ones(N, 1); % fallback
        end
      end
      nfft = max(256, 2^nextpow2(N));
      X = fft(x .* win, nfft);
      % Periodogram scaling consistent with PSD (units of power/Hz)
      U = sum(win.^2); % window power
      Pxx_two_sided = (abs(X).^2) / (fs * U);
      if rem(nfft, 2) == 0
        % even nfft
        Pxx = Pxx_two_sided(1:(nfft/2 + 1));
        Pxx(2:end-1) = 2 * Pxx(2:end-1);
      else
        % odd nfft
        Pxx = Pxx_two_sided(1:((nfft + 1)/2));
        Pxx(2:end) = 2 * Pxx(2:end);
      end
      F = linspace(0, nyquist, numel(Pxx)).';
    end

    % Compute band and total power via integration over frequency
    idx_total = (F >= 0) & (F <= nyquist);
    idx_band = (F >= band_low) & (F <= band_high);

    if ~any(idx_band) || ~any(idx_total)
      proportion(channel_index) = 0;
      continue;
    end

    total_power = trapz(F(idx_total), Pxx(idx_total));
    band_power = trapz(F(idx_band), Pxx(idx_band));

    if total_power <= 0
      proportion(channel_index) = NaN;
    else
      proportion(channel_index) = band_power / total_power;
    end
  end

  % Return scalar for vector input
  if num_channels == 1
    proportion = proportion(1);
  end
end