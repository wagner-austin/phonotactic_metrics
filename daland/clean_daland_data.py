"""
daland_cleaning.py - Module for cleaning and preparing Daland dataset files.
--------------------------------------------------------------
Version: 1.0.0
"""

import pandas as pd

# Directory containing the Daland files
data_dir = "daland/"

# Read the main scores CSV file
df = pd.read_csv(f"{data_dir}daland-scores.csv")


def clean_word(row):
    """
    Clean a word from the 'phono_cmu' column of a dataframe row.
    
    This function removes numeric digits from each token in the 'phono_cmu' column,
    removes the substring "Coda", and trims extra whitespace.
    
    Parameters:
      row (pd.Series): A row from the dataframe with a 'phono_cmu' column.
    
    Returns:
      str: The cleaned word.
    """
    word = row["phono_cmu"]
    no_numbers = " ".join([''.join(ch for ch in token if not ch.isdigit()) 
                           for token in word.split()])
    return no_numbers.replace("Coda", "").strip()


# Create a new 'word' column by applying the clean_word function to each row
df["word"] = df.apply(clean_word, axis=1)

# Write the cleaned test data (words only) to CSV without header or index
df["word"].to_csv(f"{data_dir}daland-test-data.csv", index=False, header=False)


def clean_metric_output(pre=''):
    """
    Clean the metric output CSV file.
    
    This function reads a CSV file named 'daland_original_metric_output.csv' with an optional prefix,
    replaces any occurrence of negative infinity (-inf) with -50, updates the 'rating' column with values
    from the 'likert_rating' column of the main dataframe, and writes the cleaned data to a new CSV file.
    
    Parameters:
      pre (str): Optional prefix for the CSV file name. Defaults to an empty string.
    """
    df_metric = pd.read_csv(f"{data_dir}{pre}daland_original_metric_output.csv")
    df_metric.replace(float('-inf'), -50, inplace=True)
    df_metric["rating"] = df["likert_rating"]
    df_metric.to_csv(f"{data_dir}{pre}daland_cleaned_metric_output.csv", index=False)


# Clean the metric output files using both the default and 'new_' prefix
clean_metric_output()
clean_metric_output('new_')