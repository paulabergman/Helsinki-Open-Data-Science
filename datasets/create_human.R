
# The Human Development Index (HDI) is a summary measure of achievements 
# in key dimensions of human development
# data from kaggle: https://www.kaggle.com/undp/human-development
# Tuomo Nieminen 2017

# meta
# browseURL("https://www.kaggle.com/undp/human-development")

# libraries
library(dplyr)

# read human develop data
hd <- read.csv("human_development.csv", stringsAsFactors = F)

# read gender inequality data
gii <- read.csv("gender_inequality.csv", stringsAsFactors = F, na.strings = "..")

# rename human development variables
names(hd) <- c("HDI.Rank", "Country", "HDI", "Life.Expectancy", "Education.Expected", "Education.Mean", "GNI", "GNI.Minus.Rank")

# rename gender inequality variables
names(gii) <- c("GII.Rank", "Country", "GII", "Maternal.Mortality", 
                "Adolescent.Birth", "Percent.Parliament", "Edu2.Female", "Edu2.Male", 
                "Labour.Female", "Labour.Male")

# deal with comma  separator for 1000
hd$GNI <- gsub(",","",hd$GNI) %>% as.numeric

# do a bit of feature engineering
gii <- mutate(gii, Odds.Edu2 = Edu2.Female / Edu2.Male, Odds.Labour = Labour.Female / Labour.Male)

# join data
human <- inner_join(hd, gii, by = "Country")

# exclude unneeded variables
keep <- c("Country", "Odds.Edu2", "Odds.Labour", "Education.Expected", "GNI", "Maternal.Mortality", "Percent.Parliament")
human <- select(human, one_of(keep))

# remove rows with NA values
human <- filter(human, complete.cases(human))

# remove 'World' observation
human <- slice(human, -nrow(human))

# add rownames as countries and remove country variable
rownames(human) <- human$Country
human <- select(human, -Country)


library(GGally)
# ggpairs(human)


# pca 
#---

# center
human_ <- scale(human)

# pca
pc <- prcomp(human_)

# plot
library(ggfortify)
autoplot(pc, data = human_, label = T, loadings =T, loadings.label  = T, label.size = 2.5, size = 0, loadings.label.size = 6)