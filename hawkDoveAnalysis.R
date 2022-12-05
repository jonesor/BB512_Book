library(tidyverse)
library(readxl)
library(janitor)

hdg <- readxl::read_xlsx("/Users/jones/Dropbox/_SDU_Teaching/BB512/Practicals/HawkAndDoveGame/gametheoryResults.xlsx", sheet = 3) %>%
  clean_names() %>%
  select(individual, round, player_1, player_2, benefit)


# Does hawkishness change during the game?
hawkishness <- hdg %>%
  mutate(hawkNumeric_player1 = ifelse(player_1 == "H", 1, 0)) %>%
  group_by(round) %>%
  summarise(meanHawk = mean(hawkNumeric_player1))

ggplot(hawkishness,aes(x = round,y = meanHawk)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  ggtitle("Hawkishness doesn't decline much with\ntime for Game 1")

# How does the hawkishness of individuals relate to the benefits recieved?
perIndiv <- hdg %>%
  mutate(hawkNumeric_player1 = ifelse(player_1 == "H", 1, 0)) %>%
  group_by(individual) %>%
  summarise(meanHawkishness = mean(hawkNumeric_player1), benefit = sum(benefit, na.rm = TRUE))

ggplot(perIndiv,aes(x = meanHawkishness,y = benefit)) + 
  geom_point() + 
  geom_smooth(method="lm", formula=y~poly(x, 2))+
  ggtitle("The best strategy in Game 1\nis an intermediate level of hawkishness")

# GAME 2

hdg2 <- readxl::read_xlsx("/Users/jones/Dropbox/_SDU_Teaching/BB512/Practicals/HawkAndDoveGame/gametheoryResults.xlsx", sheet = 4) %>%
  clean_names() %>%
  select(individual, round, player_1, player_2, benefit)

hdg2


# Does hawkishness change during the game?
hawkishness <- hdg2 %>%
  mutate(hawkNumeric_player1 = ifelse(player_1 == "H", 1, 0)) %>%
  group_by(round) %>%
  summarise(meanHawk = mean(hawkNumeric_player1))

ggplot(hawkishness,aes(x = round,y = meanHawk)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  ggtitle("Hawkishness declines with time for Game 2")



# How does the hawkishness of individuals relate to the benefits recieved?
perIndiv <- hdg2 %>%
  mutate(hawkNumeric_player1 = ifelse(player_1 == "H", 1, 0)) %>%
  group_by(individual) %>%
  summarise(meanHawkishness = mean(hawkNumeric_player1), benefit = sum(benefit, na.rm = TRUE))

ggplot(perIndiv,aes(x = meanHawkishness,y = benefit)) + 
  geom_point() + 
  geom_smooth(method="lm", formula=y~poly(x, 2))+
  ggtitle("The best strategy in Game 2\nwas to be a hawk")
