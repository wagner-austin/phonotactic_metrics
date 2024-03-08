import pandas as pd

dir = "scholes/"

# Clean training data
onset_dict = dict()
with open(f"{dir}onset_type_frequencies.txt", "r") as file:
    for line in file:
        line = line.strip()
        onset_dict[line] = onset_dict.get(line, 0) + 1
onset_to_freq = {onset : str(onset_dict[onset]) for onset in onset_dict}

with open(f"{dir}onset_training_data.csv", "w") as file:
    for onset,freq in onset_to_freq.items():
        file.write(onset + "," + freq + "\n")

# Clean test data
test_file = f"{dir}EnglishTableau.txt"

onsets = []
ratings = []
with open(test_file, "r") as file:
    for line in file:
        tokens = line.strip().split("\t")
        if "Scholes" in tokens:
            onsets.append(tokens[0].strip())
            ratings.append(float(tokens[-1].strip()))
        else:
            break

with open(f"{dir}scholes_cleaned_test_data.csv", "w") as file:
    for onset in onsets:
        file.write(onset + "\n")

# Clean metric output csv
df = pd.read_csv(f"{dir}scholes_original_metric_output.csv")
df.replace(float('-inf'), -10, inplace=True)
df["rating"] = ratings
df.to_csv(f"{dir}scholes_cleaned_metric_output.csv", index=False)