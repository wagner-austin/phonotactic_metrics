import pandas as pd

dir = "needle/"

df = pd.read_csv(f"{dir}needle_data.csv")

# Map DISC to CMU representation of sounds

disc_to_cmu = dict()

for index, row in df.iterrows():
    sounds = row["cmu"].split()
    for i in range(len(row["disc"])):
        char = row["disc"][i]
        disc_to_cmu[char] = sounds[i]

# For training data, convert sounds from DISC to CMU, and write to new file
lines = []
with open(f'{dir}needle_orig_training.txt', 'r') as file:
    for line in file:
        representations = line.strip().split(",")
        cmu_repr = [disc_to_cmu[char] for char in representations[1]]
        lines.append(' '.join(cmu_repr))
with open(f'{dir}needle_cleaned_training.txt', 'w') as file:
    for line in lines:
        if len(line) != 0:
            file.write(line + "\n")

# Create test file
df["cmu"].to_csv(f"{dir}needle_test_data.csv", header=False, index=False)

# Clean metric output csv
def clean_metric_output(pre=''):
    df_metric = pd.read_csv(f"{dir}{pre}needle_original_metric_output.csv")
    df_metric.replace(float('-inf'), -50, inplace=True)
    if "subject" not in df_metric.columns:
        df_metric.insert(loc=0, column="subject", value=df["subjID"])
    df_metric["rating"] = df["rating"]
    df_metric.to_csv(f"{dir}{pre}needle_cleaned_metric_output.csv", index=False)

clean_metric_output()
clean_metric_output('new_')