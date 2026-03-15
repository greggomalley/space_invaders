# Space Invaders

Scans a radar file for known space invader patterns using Hamming distance scoring with noise tolerance.

## Usage

```
ruby space_invaders.rb [options] radar_file
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `-f, --format FORMAT` | `terminal` | Output format(s): `terminal`, `html` (comma-separated) |
| `-t, --threshold FLOAT` | `0.7` | Match threshold between 0 and 1 |

### Examples

```bash
# Basic scan with terminal output
ruby space_invaders.rb config/radar/radar_1.txt

# Output as HTML
ruby space_invaders.rb --format html config/radar/radar_1.txt

# Both terminal and HTML at once
ruby space_invaders.rb --format terminal,html config/radar/radar_1.txt

# Stricter matching
ruby space_invaders.rb --threshold 0.9 config/radar/radar_1.txt

# Combine options
ruby space_invaders.rb --format terminal,html --threshold 0.8 config/radar/radar_1.txt
```

## Docker

Build the image:

```bash
make build
```

Run with the default radar file (`config/radar/radar_1.txt`):

```bash
make run
```

Run with a different radar file:

```bash
make run RADAR=config/radar/radar_2.txt
```

Run directly with Docker and pass any options:

```bash
docker run space_invaders ruby space_invaders.rb --format terminal
```

## Design

### Detection
The binary nature of the radar made a boolean matrix the obvious representation. The problem is similar to
one I deal with regularly, matching video frames against a stream using a sliding window to detect adverts,
so the approach seemed like a natural fit. In that domain Hamming distance is the standard measure for
comparing binary fingerprints, and it maps well here: XOR the two matrices and count the differing bits,
giving a normalised score between 0 and 1. It handles both false positives (extra bits in the radar) and
false negatives (missing bits) symmetrically, since XOR counts a differing bit regardless of which direction
it flipped.

A minimum overlap is also enforced - a match is only considered if the visible portion of the invader covers
at least half its total area, preventing a single bit at the corner of the radar from scoring a near-perfect
match against a near-empty slice.

### Edge & Partial Matching
We create a window that extends beyond the radar bounds to handle partial matches at borders — an invader
starts almost entirely off-screen (only its bottom-right corner overlapping the top-left of the radar) and
finishes the same way at the opposite corner. At each position, the visible slice of the invader and the
corresponding slice of the radar are clipped to what's actually on screen, and only those regions are
compared. This means invaders can be detected at negative coordinates, e.g. (-2, 0), meaning the invader's
left two columns are off the left edge of the radar.

### Clustering
Often after scanning, the sliding window produces multiple overlapping candidates. To deduplicate, we use a
basic algorithm that sorts candidates by score, takes the best one, throws away anything that overlaps with
it, regardless of invader type, then repeats until all candidates have been kept or discarded.