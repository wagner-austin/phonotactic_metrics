import pandas as pd

dir = "spanish/"

# Replace pre with empty string '' for original files (no unigram smoothing)
pre = 'new_'
df = pd.read_csv(f"{dir}{pre}spanish_responses_phonotactics_paper_scored.csv")

# Replace -Inf values with small negative value (e.g. -50) for regression models to work
df.replace(float('-inf'), -50, inplace=True)
df.to_csv(f"{dir}{pre}spanish_cleaned_metric_output.csv", index=False)