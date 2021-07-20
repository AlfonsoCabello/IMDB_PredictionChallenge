# IMDB Prediction Challenge

## Objective:

Movies are a form of art where its creators express their ideas and feelings through fictionor non-fiction, and as all expressive arts, their likeability depends, mostly, on their viewers’interpretations. 

However, apart from these deviations in likings, some movies are generallyloved or hated unanimously which leads to the following questions:
  • What really makes a movie a success or a disaster?
  • Can I hack the system and tailor the perfect movie for my target audience? If so, whatmovie should I produce to get high ratings?

Using IMDb’s movie database, the following report seeks to answer these questions throughregression analysis on IMDb’s user rating score.  This score is completely based on userreviews which, combined with IMDb’s high user engagement, leads to a score that shouldrepresent the true rating of these films.

Our analysis concludes that movie ratings are in fact correlated to specific factors like movielength, certain genres, and quality (directors, production companies, budget size) lead tobetter or worse movies from an audience perspective1.  Given this, we have developed apredictive model with an MSE equal to 0.5403 points when tested.This leads us to safelysuggest that the specific mix of factors, when combined accordingly, may lead to higherratings in movies.

Finally, we believe the predictive accuracy of our model can be increased if additional dataon movies is captured. We consider the movie plot is one of the key factors that make amovie successful and this type of information cannot be captured with the available IDMBdatabase. For future analysis, we encourage using text analytics to extract specific detailson the movie plot from its summary as successful patterns may be found.

## Data Description:

The movie dataset contains 51 variables for 2995 movies, spanning across 100 years in 46countries. The dataset includes a variety of variables providing information on the genre ofmovie, language, actors acted in the movie, details about director and editors.

In this analysis,“IMDb Score”is the target variable while others are the possible predictors.However, based on the model, we are focusing on only the predictors which have the highestpredictive power in determining the IMDb score.

## Model Build-up:

See code attached.

## Results:

The genres, such as drama, action, comedy, horror, documentary, family, and animation, significantly impact the IMDb score.

1) Using the results, it can be inferred that drama, action, and family movies tend tohave low scores than movies with other genres. For example, the movie with genreaction has 0.26 less IMDb score as compared to movies categorized with other genres,provided all other conditions are the same. Similarly, we can compare how the genrementioned above impacts the IMDb scores using Table 78and corresponding coefficientvalues.
2) Movies with genre comedy, documentary, and animation has a positive impact onIMDb scores. So, the movies with the genre mentioned above tend to get more scoresthan other genres, keeping other factors such as budget, duration, etc. constant.
  a) The animated movie will have 0.52 more IMDb score than any other non-animatedmovie, provided all other conditions are the same.
  b) The drama movies also attract more scores from the reviewers. On an averagethe drama movies have 1.16 more scores than movies that are not from dramagenre. Similarly, we    can compare how the genre, as mentioned earlier, impacts the IMDbscores using Table 78and corresponding coefficient values. It is recommended tothe producer and directors    to make movies of genre Comedy, Drama, Animationand Documentary since they are more liked by the viewer. Furthermore, we alsosuggest that it is better to avoid Action        movies, Horror movies and Family movieas they strike low IMDb scores.

The movie genre impacts the IMDb score to some extent; however, the other combinationof factors such as runtime of the drama movie; runtime of the comedy movie and a drama & action movie also plays the crucial role in predicting the IMDb score.
1) The comedy and drama movie with longer run time tends to have a lower rating ascompared to movies which does not belongs to comedy or drama genre. In other words, it is advisable to have a short duration of comedy and drama movies to have a higherIMDb Score.
2) The action-drama movie is also not a good option to invest movie in, as the combinationgenerally have lower by 0.18 IMDb scores as compared to a drama or an action movieseparately

Some other factors tend to affect the IMDb score of the movie. Please note that the analysisis done when one parameter is changed, and the other parameter remains constant.
1) Movies directed by Jason Friedberg have a lower IDMB score compared to moviesdirected by other directors.
2) Movies that were produced by Dimension Films tend to have a lower IMDb score by 0.53 than movies produced by any other production company.
3) Movies produced in the United Kingdom have higher IMDb scores by 0.18 comparedto movies produced in any other country.
4) Movies with the main actor as females have lower IMDb scores by 0.20 than the moviesin which the main role is played by a male.

So, the factors that account for the movie with a high rating, which the producers anddirectors should also keep in mind while making a movie. Just to summarize, the factorsthat affect the scores in a positive fashion and negative fashion, respectively.
  - Positive Factors - Comedy Movie, Drama Movie, Documentary Movie, Animated Movie,Movie Produced in UK.
  - Negative Factors – Action Movie, Main Actor as Female, Horror Movie, Family Movie, MovieDirected by Jason Friedberg, Movie Produced by Dimension Films, Drama-Action Movie.

## Contributors
This project was a team effort where I got to work with these awesome people:

Tarash Jain<br> 
[![GitHub Badge](https://img.shields.io/badge/GitHub-Profile-informational?style=flat&logo=github&logoColor=white&color=0D76A8)](https://github.com/tarashjain)

Sebastian Salazar<br>
[![GitHub Badge](https://img.shields.io/badge/GitHub-Profile-informational?style=flat&logo=github&logoColor=white&color=0D76A8)](https://github.com/sebsalazar94)

Siddharth Singhal<br>
[![GitHub Badge](https://img.shields.io/badge/GitHub-Profile-informational?style=flat&logo=github&logoColor=white&color=0D76A8)](https://github.com/siddharthsinghal01)

Anukriti Yadav<br>
[![GitHub Badge](https://img.shields.io/badge/GitHub-Profile-informational?style=flat&logo=github&logoColor=white&color=0D76A8)](https://github.com/anukriti21)

<br> 
