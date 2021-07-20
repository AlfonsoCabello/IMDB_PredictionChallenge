# MIDTERM CODE #

###########################################################################
# Section 1-A :To build the model. '
# Section 1-B: To predict the IMDb score

###########################################################################

###################-------------------- SECTION-1A--------------------########################

# (1) DATA PREPARATION #########################################

start=Sys.time()
# (A) Import data and drop useless variables
movies <- read.csv("C:/Users/HP-073/Desktop/Master of Management in Analytics (McGill)/Fall 2020/MGSC661 - Multivariate Stats for Machine Learning/E) Midterm/films_fall_2020.csv", encoding = "UTF-8")
movies <- subset(movies, select = -c(imdb_id,imdb_url,title)) # Do not matter
movies <- subset(movies, select = -c(genre_realitytv, genre_shortfilm)) # All values are 0 
attach(movies)

# (B) Continuous and binary variables correlation filter
movies_num <- subset(movies, select = -c(main_lang,main_actor1_name,main_actor2_name,main_actor3_name,main_director_name,
                                         main_producer_name,editor_name,main_production_company,main_production_country)) 

variables=c('imdb_score')
corr_y_x=c()
for (i in 2:(length(colnames(movies_num)))) {
  if (abs(cor(imdb_score,movies_num[i]))>=0.00) { ## 0.15 (Original filter used 0.15 of correlation. However, the final model includes some variables with lower correlation)
    corr_y_x=c(corr_y_x,c(colnames(movies_num[i]),round(cor(imdb_score,movies_num[i]),4)))
    variables=c(variables,colnames(movies_num[i]))
  }
}

# (C) Categorical variables correlation filter (dummifying categories)
install.packages("fastDummies")
library(fastDummies)

cat_var<- subset(movies, select = c(imdb_score,main_lang,main_actor1_name,main_actor2_name,main_actor3_name,main_director_name,
                                    main_producer_name,editor_name,main_production_company,main_production_country)) 

for (j in 2:(length(colnames(cat_var)))) {
  movies_cat <- cat_var[,c(1,j)]
  movies_cat <- dummy_cols(movies_cat, remove_selected_columns = TRUE)
  
  
  for (i in 2:(length(colnames(movies_cat)))) {
    if (abs(cor(imdb_score,movies_cat[i]))>=0.1) { ## Original filter for categorical variables
      corr_y_x=c(corr_y_x,c(colnames(movies_cat[i]),round(cor(imdb_score,movies_cat[i]),4)))
      variables=c(variables,colnames(movies_cat[i]))
    }
  }
}

# (D) Filtering data on final variables
movies_filtered <- dummy_cols(movies, remove_selected_columns = TRUE)
idx <- match(variables, names(movies_filtered))
movies_filtered <- movies_filtered[,idx] 

remove(cat_var,idx,i,j, movies_cat, movies_num, movies,corr_y_x)


# (2) MODELLING AND FIT #########################################

# (A) Remove outliers
attach(movies_filtered)
mregF_1=lm(imdb_score~poly(year_of_release,2)+poly(duration_in_hours,4)+poly(total_number_of_actors,2)+poly(budget_in_millions,3)+
             genre_action+genre_comedy+genre_drama+genre_horror+genre_documentary+genre_family+genre_animation+genre_adventure+
             `main_director_name_Jason Friedberg`+editor_name_none+`main_production_company_Dimension Films`+`main_production_country_United Kingdom`)

require(lmtest)
require(plm)
library(car)
outlierTest(mregF_1)
movies_filtered_no_outliers=movies_filtered[-c(907,2071,532,2342),]

attach(movies_filtered_no_outliers)


# (B) Fit final model
#MSE = 0.5386
library(boot)
set.seed(1)
fit_final= glm(imdb_score~poly(year_of_release,3)+
                poly(duration_in_hours,4)+
                poly(total_number_of_actors,2)+
                poly(budget_in_millions,3)+
                genre_drama*genre_action+
                genre_comedy*duration_in_hours+
                genre_drama*duration_in_hours+
                main_actor1_is_female+
                genre_action+
                genre_comedy+
                genre_drama+
                genre_horror+
                genre_documentary+
                genre_family+
                genre_animation+
                editor_name_none+
                `main_director_name_Jason Friedberg`+
                `main_production_company_Dimension Films`+
                `main_production_country_United Kingdom`,
              data=movies_filtered_no_outliers)
mse=cv.glm(movies_filtered_no_outliers,fit_final,K=30)$delta[1]
end=Sys.time()


print(paste('Final model MSE (Folds=10):',round(mse,4)))
print(paste('Run time:',round(end-start,4)))

###################-------------------- END OF SECTION-1A --------------------########################



###################-------------------- SECTION 1B --------------------########################

# (1) DATA PREPARATION #########################################

# (A) Load test dataset
test_movies <- read.csv("C:/Users/HP-073/Desktop/Master of Management in Analytics (McGill)/Fall 2020/MGSC661 - Multivariate Stats for Machine Learning/E) Midterm/predict_2.csv", encoding = "UTF-8")

variables_for_modelling= c('year_of_release','duration_in_hours', 'total_number_of_actors', 'budget_in_millions',
                           'main_actor1_is_female',
                           'genre_action', 'genre_comedy', 'genre_drama', 'genre_horror', 'genre_documentary', 'genre_family', 'genre_animation',
                           'editor_name_none', 'main_director_name_Jason Friedberg','main_production_company_Dimension Films', 'main_production_country_United Kingdom')

# (B) Dummify dataset
library(fastDummies)
test_movies_filtered <- dummy_cols(test_movies, remove_selected_columns = TRUE)

nms <- c('year_of_release','duration_in_hours', 'total_number_of_actors', 'budget_in_millions',
         'main_actor1_is_female',
         'genre_action', 'genre_comedy', 'genre_drama', 'genre_horror', 'genre_documentary', 'genre_family', 'genre_animation',
         'editor_name_none', 'main_director_name_Jason Friedberg','main_production_company_Dimension Films', 'main_production_country_United Kingdom')   # Vector of columns you want in this data.frame



Missing <- setdiff(nms, names(test_movies_filtered))  # Find names of missing columns
test_movies_filtered[Missing] <- 0                    # Add them, filled with '0's
test_movies_filtered <- test_movies_filtered[nms]     # Put columns in desired order


remove(test_movies, nms)

# (2) PREDICTING #########################################
predict(fit_final,test_movies_filtered)


###################-------------------- END OF SECTION-1B --------------------########################