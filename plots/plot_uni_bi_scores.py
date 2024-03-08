import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os

def make_uni_bi_score_plot(data_path, uni_col, bi_col, response_col, save_path=None):
    df = pd.read_csv(data_path)
    num_words = len(df)

    # Response data
    responses = df[response_col]

    # Unigram/Bigram scores
    uni_scores = df[uni_col]
    bi_scores = df[bi_col]

    # Do not make plot if any data points are null
    if uni_scores.isna().any() or bi_scores.isna().any():
        return

    # Standardized unigram/bigram scores
    standardized_uni_scores = (uni_scores - uni_scores.mean()) / uni_scores.std()
    standardized_bi_scores = (bi_scores - bi_scores.mean()) / bi_scores.std()

    # Medians of standardized unigram/bigram scores
    uni_median = standardized_uni_scores.median()
    bi_median = standardized_bi_scores.median()

    # Indices of words with low/high unigram/bigram scores
    low_uni_indices = []
    high_uni_indices = []
    low_bi_indices = []
    high_bi_indices = []

    for i in range(num_words):
        if standardized_uni_scores[i] <= uni_median:
            low_uni_indices.append(i)
        else:
            high_uni_indices.append(i)
        if standardized_bi_scores[i] <= bi_median:
            low_bi_indices.append(i)
        else:
            high_bi_indices.append(i)

    # Data for plotting on x-axis (uni/bi scores)
    x_data = [standardized_uni_scores[low_bi_indices], standardized_uni_scores[high_bi_indices],
                 standardized_bi_scores[low_uni_indices], standardized_bi_scores[high_uni_indices]]
    
    # Data for plotting on y-axis (response scores)
    y_data = [responses[low_bi_indices], responses[high_bi_indices],
              responses[low_uni_indices], responses[high_uni_indices]]
    
    # Plot titles
    titles = ["Low bigram", "High bigram", "Low unigram", "High unigram"]

    fig, axs = plt.subplots(1, 4, figsize=(12,4))

    for i, ax in enumerate(axs):
        x_points, y_points = x_data[i], y_data[i]

        # Plot uni/bi score vs response data
        ax.scatter(x_points, y_points)

        # Calculate and plot trend-line
        fit = np.polyfit(x_points, y_points, 1)
        poly = np.poly1d(fit)
        ax.plot(x_points, poly(x_points), 'r')

        ax.set_title(titles[i])
        # Set x-label based on plotted data
        if i < 2:
            ax.set_xlabel('Unigram score')
        else:
            ax.set_xlabel('Bigram score')

    # Adjust the horizontal space between subplots and space below plots
    plt.subplots_adjust(wspace=0.3, bottom=0.15)

    # Set y-label for leftmost plot
    axs[0].set_ylabel('Response', labelpad=15)

    if save_path:
        plt.savefig(save_path)
    else:
        plt.show()

def plots_driver(datasets='all', best_model_only=True):
    all_datasets = ['albright', 'daland', 'needle', 'polish', 'scholes', 'spanish', 'turkish', 'white_hayes']
    datasets = all_datasets if datasets == 'all' else datasets

    file_paths = {dataset : f"{dataset}/{dataset}_cleaned_metric_output.csv" for dataset in datasets}
    file_paths['polish'] = 'polish/cleaned_response_data.csv'

    model_to_columns = {
        'uni_bi' : ['uni_prob', 'bi_prob'],
        'uni_bi_smoothed' : ['uni_prob', 'bi_prob_smoothed'],
        'uni_bi_freq' : ['uni_prob_freq_weighted', 'bi_prob_freq_weighted'],
        'uni_bi_freq_smoothed' : ['uni_prob_freq_weighted', 'bi_prob_freq_weighted_smoothed'],
        'pos_uni_bi' : ['pos_uni_score', 'pos_bi_score'],
        'pos_uni_bi_smoothed' : ['pos_uni_score_smoothed', 'pos_bi_score_smoothed'],
        'pos_uni_bi_freq' : ['pos_uni_score_freq_weighted', 'pos_bi_score_freq_weighted'],
        'pos_uni_bi_freq_smoothed' : ['pos_uni_score_freq_weighted_smoothed', 'pos_bi_score_freq_weighted_smoothed']
    }

    # If best_model_only == True, then only the model that performed the best will be be plotted
    #   For Polish, Scholes, White/Hayes data, this is the uni_bi_freq_smoothed model
    #   For all other datasets, this is the uni_bi_smoothed model
    # Otherwise, for each dataset, the results of every valid model will be plotted
    models_to_plot = {
        dataset : (
            ['uni_bi_freq_smoothed'] if dataset in {'polish', 'scholes', 'white_hayes'} else ['uni_bi_smoothed']
        ) if best_model_only else model_to_columns.keys()
        for dataset in datasets
    }

    for dataset in datasets:
        if not os.path.exists(f"plots/{dataset}"):
            os.makedirs(f"plots/{dataset}")
        rating_col = 'response' if dataset in {'polish', 'spanish', 'turkish'} else 'rating'
        for model in models_to_plot[dataset]:
            uni_bi_columns = model_to_columns[model]
            save_path = f"plots/{dataset}/{dataset}_{model}.png"
            make_uni_bi_score_plot(file_paths[dataset], uni_bi_columns[0], uni_bi_columns[1], rating_col, save_path)

if __name__ == '__main__':
    plots_driver(datasets='all', best_model_only=True)
