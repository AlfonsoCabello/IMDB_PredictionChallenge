# MIDTERM CODE #

###########################################################################
# Section 1A : Train and fit the model
# Section 1B : Predict based on new dataset 
# Section 2 :  Details Code including garph and other analysis
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


###################-------------------- END OF SECTION-1 --------------------########################


###################-------------------- SECTION-2 --------------------###############################


# (1) DATA FILTERING #########################################

# (A) Import data and drop useless variables
movies <- read.csv("D:/OneDrive - McGill University/Desktop/McGill MMA/Courses/Fall/Multivariate Stats- Machine Learning/films_fall_2020.csv", encoding = "UTF-8")
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

install.packages("fastDummies")
# (C) Categorical variables correlation filter (dummifying categories)
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


# (2) DATA ANALYSIS (CORRELATION MATRIX) #########################################

# (A) Database of final model for graphing
movies_filtered_2<- subset(movies_filtered, select = c(imdb_score,year_of_release,duration_in_hours,total_number_of_actors,budget_in_millions,
                                                       genre_action,genre_comedy,genre_drama,genre_horror,genre_documentary,genre_family,genre_animation,
                                                       main_actor1_is_female,
                                                       `main_director_name_Jason Friedberg`,`editor_name_none`,`main_production_company_Dimension Films`,`main_production_country_United Kingdom`))

# (B) Change variable names for graphing
names(movies_filtered_2) <- c('IMDb Score','Year of release','Duration (hours)','Number of actors','Budget (US$ millions)',
                              'Genre: Action','Genre: Comedy','Genre: Drama','Genre: Horror','Genre: Documentary','Genre: Family','Genre: Animation',
                              '1st main actor(Female)',
                              'Director: J. Friedberg','Editor: None','Prod. company: Dimension Films','Prod. country: UK')

# (C) Correlation heatmap
install.packages("GGally")
install.packages("ggthemes")
install.packages("ggrepel")
install.packages("scales")
install.packages("corrplot")
library(GGally)
library(ggplot2) # visualization
library(ggrepel)
library(ggthemes) # visualization
library(scales) # visualization
library(corrplot)

corr_base <- movies_filtered_2
names(corr_base) <- c('Score','Year','Duration','Num actors','Budget',
                      'Action','Comedy','Drama','Horror','Documentary','Family','Animation',
                      'Actor1(F)',
                      'Director:J.Friedberg','Editor:None','Prod:Dim Films','UK')

ggcorr(corr_base, nbreaks = 10, low = "black", high = "gold", label_round = 2, label_size = 0.25, size = 2.25, hjust =0.5)

# (3) DATA ANALYSIS (GGPLOTS) #########################################
install.packages("ggpubr")
library(ggplot2)
library(ggpubr)


# (A) IMBD Score
ggplot(movies_filtered_2, aes(x = `IMDb Score`)) +
  geom_histogram(aes(fill = ..count..), binwidth =0.5) +
  scale_x_continuous(name = "IMDB Score",
                     breaks = seq(0,10),
                     limits=c(1, 10)) +
  ggtitle("Histogram of Movie IMDB Score") +
  scale_fill_gradient("Count", low = "grey", high = "gold")

# (B) Year of Release
desc_1= ggplot(movies_filtered_2, aes(`Year of release`)) +
  geom_histogram(binwidth=3,color='gold',fill="#8c8c8c") +
  labs(y = "# movies", title = "Movies by Year") +
  theme(plot.title = element_text(hjust = 0.5))

plot_1= ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=`Year of release`))+
  geom_point(color="#8c8c8c",size=1)+
  geom_smooth(method='lm', formula=y~poly(x,3, raw=FALSE), color='gold')+
  labs(title='VS. IMDb Score')+
  theme(plot.title = element_text(hjust = 0.5),legend.position='top',legend.justification = 'left')

ggarrange(desc_1,plot_1)

# (C) Duration in Hours
desc_2= ggplot(movies_filtered_2, aes(`Duration (hours)`)) +
  geom_histogram(color='gold',fill="#8c8c8c") +
  labs(y = "# movies", title = "Movies by Duration") +
  theme(plot.title = element_text(hjust = 0.5))

plot_2= ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=`Duration (hours)`))+
  geom_point(color="#8c8c8c",size=1)+
  geom_smooth(method='lm', formula=y~poly(x,4, raw=FALSE), color='gold')+
  labs(title='VS. IMDb Score')+
  theme(plot.title = element_text(hjust = 0.5),legend.position='top',legend.justification = 'left')

ggarrange(desc_2,plot_2)

# (D) Number of actors
desc_3= ggplot(movies_filtered_2, aes(`Number of actors`)) +
  geom_histogram(color='gold',fill="#8c8c8c") +
  labs(y = "# movies", title = "Movies by Number of Actors") +
  theme(plot.title = element_text(hjust = 0.5))

plot_3= ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=`Number of actors`))+
  geom_point(color="#8c8c8c",size=1)+
  geom_smooth(method='lm', formula=y~poly(x,2, raw=FALSE), color='gold')+
  labs(title='VS. IMDb Score')+
  theme(plot.title = element_text(hjust = 0.5),legend.position='top',legend.justification = 'left')

ggarrange(desc_3,plot_3)

# (E) Budget ($ MM)
desc_4= ggplot(movies_filtered_2, aes(`Budget (US$ millions)`)) +
  geom_histogram(color='gold',fill="#8c8c8c") +
  labs(y = "# movies", title = "Movies by Budget") +
  theme(plot.title = element_text(hjust = 0.5))

plot_4= ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=`Budget (US$ millions)`))+
  geom_point(color="#8c8c8c",size=1)+
  geom_smooth(method='lm', formula=y~poly(x,3, raw=FALSE), color='gold')+
  labs(title='VS. IMDb Score')+
  theme(plot.title = element_text(hjust = 0.5),legend.position='top',legend.justification = 'left')

ggarrange(desc_4,plot_4)

# (F) Genre Boxplots
box_1=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Action`))) +
  geom_boxplot()+
  labs(x='Genre: Action') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_2=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Comedy`))) +
  geom_boxplot()+
  labs(x='Genre: Comedy') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_3=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Drama`))) +
  geom_boxplot()+
  labs(x='Genre: Drama') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_4=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Horror`))) +
  geom_boxplot()+
  labs(x='Genre: Horror') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_5=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Documentary`))) +
  geom_boxplot()+
  labs(x='Genre: Documentary') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_6=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Family`))) +
  geom_boxplot()+
  labs(x='Genre: Family') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_7=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Genre: Animation`))) +
  geom_boxplot()+
  labs(x='Genre: Animation') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

ggarrange(box_1,box_2,box_3, box_4,
          box_5,box_6,box_7,
          nrow = 2, ncol = 4)

# (F) Categorical Boxplots
box_1=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`1st main actor(Female)`))) +
  geom_boxplot()+
  labs(x='1st main actor-Female') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_2=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Director: J. Friedberg`))) +
  geom_boxplot()+
  labs(x='Director: J. Friedberg') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_3=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Editor: None`))) +
  geom_boxplot()+
  labs(x='Editor: None') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_4=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Prod. company: Dimension Films`))) +
  geom_boxplot()+
  labs(x='Prod. company: Dimension Films') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))

box_5=  ggplot(movies_filtered_2, aes(y=`IMDb Score`,x=as.factor(`Prod. country: UK`))) +
  geom_boxplot()+
  labs(x='Prod. country: UK') +
  scale_x_discrete(labels=c("No","Yes"))+
  theme(plot.title = element_text(hjust = 0.5))


ggarrange(box_1,box_2,box_3, box_4,box_5,
          nrow = 1, ncol = 5)


# (4) MODELLING PROCESS #########################################

# (A) Prefinal model

## Prefinal Model (With outliers)
attach(movies_filtered)
mregF_1=lm(imdb_score~poly(year_of_release,2)+poly(duration_in_hours,4)+poly(total_number_of_actors,2)+poly(budget_in_millions,3)+
             genre_action+genre_comedy+genre_drama+genre_horror+genre_documentary+genre_family+genre_animation+genre_adventure+
             `main_director_name_Jason Friedberg`+editor_name_none+`main_production_company_Dimension Films`+`main_production_country_United Kingdom`)
summary(mregF_1)

## Outliers
require(lmtest)
require(plm)
library(car)
outlierTest(mregF_1)
movies_filtered_no_outliers=movies_filtered[-c(907,2071,532,2342),]

attach(movies_filtered_no_outliers)
mregF_2=lm(imdb_score~poly(year_of_release,3)+poly(duration_in_hours,4)+poly(total_number_of_actors,2)+poly(budget_in_millions,3)+
             genre_action+genre_comedy+genre_drama+genre_horror+genre_documentary+genre_family+genre_animation+genre_adventure+
             `main_director_name_Jason Friedberg`+editor_name_none+`main_production_company_Dimension Films`+`main_production_country_United Kingdom`)
summary(mregF_2)

## Linearity test and ANOVA
library(car)

## Linearity test
residualPlots(mregF_2, col = carPalette()[1])

## ANOVA (going for 3 stars) - Polynomial degree determination
### Year of release (d=2)
regd1=lm(imdb_score~poly(year_of_release,1,raw=TRUE))
regd2=lm(imdb_score~poly(year_of_release,2))
regd3=lm(imdb_score~poly(year_of_release,3))
regd4=lm(imdb_score~poly(year_of_release,4))
anova(regd1, regd2, regd3, regd4)
### Duration in hours (d=4)
regd1=lm(imdb_score~poly(duration_in_hours,1,raw=TRUE))
regd2=lm(imdb_score~poly(duration_in_hours,2))
regd3=lm(imdb_score~poly(duration_in_hours,3))
regd4=lm(imdb_score~poly(duration_in_hours,4))
anova(regd1, regd2, regd3, regd4)
### Total number of actors (d=2)
regd1=lm(imdb_score~poly(total_number_of_actors,1,raw=TRUE))
regd2=lm(imdb_score~poly(total_number_of_actors,2))
regd3=lm(imdb_score~poly(total_number_of_actors,3))
regd4=lm(imdb_score~poly(total_number_of_actors,4))
anova(regd1, regd2, regd3, regd4)
### Budget in millions (d=3)
regd1=lm(imdb_score~poly(budget_in_millions,1,raw=TRUE))
regd2=lm(imdb_score~poly(budget_in_millions,2))
regd3=lm(imdb_score~poly(budget_in_millions,3))
regd4=lm(imdb_score~poly(budget_in_millions,4))
anova(regd1, regd2, regd3, regd4)

### K-Fold test for prefinal model (10 folds)
# MSE = 0.5502
library(boot)
set.seed(1)
fit_pre=glm(imdb_score~poly(year_of_release,3)+poly(duration_in_hours,4)+poly(total_number_of_actors,2)+poly(budget_in_millions,3)+
              genre_action+genre_comedy+genre_drama+genre_horror+genre_documentary+genre_family+genre_animation+genre_adventure+
              `main_director_name_Jason Friedberg`+editor_name_none+`main_production_company_Dimension Films`+`main_production_country_United Kingdom`,
            data=movies_filtered_no_outliers)
modelMSE=cv.glm(movies_filtered_no_outliers,fit_pre,K=10)$delta[1]
modelMSE

#########################################
# (B) Final model
#MSE = 0.5386
set.seed(1)
fit1= glm(imdb_score~poly(year_of_release,3)+
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
mse=cv.glm(movies_filtered_no_outliers,fit1,K=30)$delta[1]
mse
summary(fit1)
################################-------- Hope you enjoyed! -----------------#################