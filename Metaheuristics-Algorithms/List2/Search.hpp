#pragma once
#ifndef SEARCH_HPP
#define SEARCH_HPP

#include <iostream>
#include <vector>
#include <random>
#include <mutex>
#include <atomic>

#include "Graph.hpp"

class TabuSearch {
  public:
    int tabuListSize, iterations;
    std::atomic<int> weightSum;
    int minCost = INT_MAX;
    std::vector<Node> tabuList;

    TabuSearch(int tabuListSize, int iterations) : tabuListSize(tabuListSize), iterations(iterations) { }

    void runAlgorithm(std::vector<short> *cycle, Graph &graph, int weight) {
      int n = (*cycle).size();
      // std::cout << "Cycle size: " << n << ", tabuSize: " << this->tabuListSize << ", maxIterations: " << this->iterations << std::endl;
      std::vector<short> currentSolution(*cycle);
      std::vector<short> betterSolution;
      bool improvement = true;
      int iterationWithoutImprovement = 0;
      // Tabu List to store forbidden moves
      std::vector<std::vector<int>> tabuList;
      std::pair<short, short> bestInversion;
      int min = weight;
      int currCost = min;
      std::vector<std::pair<int, int>> inversions;
      for(int i = 0; i < n - 1; i++) {
        for(int j = i + 1; j < n; j++) {
          inversions.emplace_back(i, j);
        }
      }

      while(iterationWithoutImprovement < this->iterations) {
        for(const auto &inversion: inversions) { // full neighborhood - better results but slow
          auto i = inversion.first;
          auto j = inversion.second;
          if(isTabu(tabuList, i, j)) {
            continue;
          }
          if(i == 0 || j == n - 1) {
            continue;
          }
          unsigned int newSolution = graph.evaluateSolution(currentSolution, i, j, currCost);
          if(newSolution < min) {
            min = newSolution;
            bestInversion = inversion;
            // break;
          }
        }

        if(currCost > min) {
          currentSolution = graph.invert(currentSolution, bestInversion.first, bestInversion.second);
          if(tabuList.size() == this->tabuListSize) {
            tabuList.erase(tabuList.begin());
          }
          tabuList.push_back({ bestInversion.first, bestInversion.second });
          currCost = min;
          iterationWithoutImprovement = 0;
        } else {
          iterationWithoutImprovement++;
        }
      }
      if(currCost < minCost) {
        minCost = currCost;
      }
      weightSum += currCost; 
      *cycle = currentSolution;
    }

    void runRandomizedNeighborhoodAlgorithm(std::vector<short> *cycle, Graph &graph, int weight) {
      int n = (*cycle).size();
      std::vector<short> currentSolution(*cycle);
      std::vector<short> betterSolution;
      bool improvement = true;
      int iterationWithoutImprovement = 0;
      // Tabu List to store forbidden moves
      std::vector<std::vector<int>> tabuList;
      std::pair<short, short> bestInversion;
      int min = weight;
      int currCost = min;
      std::vector<std::pair<int, int>> inversions; // list of inversions
      for(int i = 0; i < n - 1; i++) {
        for(int j = i + 1; j < n; j++) {
          inversions.emplace_back(i, j);
        }
      }
      std::mt19937 gen{std::random_device{}()};
      std::uniform_int_distribution<size_t> intDist(0, inversions.size() - 1);

      while(iterationWithoutImprovement < this->iterations) {
        for(int k = 0; k < 2 * n; k++) { // n trials with random inversion
          auto inv = inversions[intDist(gen)];
          int i = inv.first;
          int j = inv.second; 
          if(isTabu(tabuList, i, j)) {
            continue;
          }
          if(i == 0 || j == n - 1) {
            continue; 
          }
          int newSolution = graph.evaluateSolution(currentSolution, i, j, currCost);
          if(newSolution < min) {
            min = newSolution;
            bestInversion = inv;
          }
        }

        if(currCost > min) {
          currentSolution = graph.invert(currentSolution, bestInversion.first, bestInversion.second);
          if(tabuList.size() == this->tabuListSize) {
            tabuList.erase(tabuList.begin());
          }
          tabuList.push_back({ bestInversion.first, bestInversion.second });
          currCost = min;
          iterationWithoutImprovement = 0;
        } else {
          iterationWithoutImprovement++;
        }
      }

      if(currCost < minCost) {
        minCost = currCost;
      }      
      weightSum += currCost; 
      *cycle = currentSolution;
    }

  private:
    std::mutex myMutex;
    bool isTabu(const std::vector<std::vector<int>> tabuList, int i, int j) {
      for(const auto &move : tabuList) {
        if(move[0] == i && move[1] == j) {
          return true;
        }
      }
      return false;
    }
};

#endif

// if(!isTabu(tabuList, i, j) && (newSolution < min)) { // || iteration == 0
//   currentSolution = graph.invert(currentSolution, i, j);
//   min = newSolution;
//   improvement = true;
//   iterationWithoutImprovement = 0;
//   betterSolution = currentSolution;

//   // Add move(i, j) to the tabu List
//   tabuList.push_back({ i, j });
//   if(tabuList.size() > this->tabuListSize) { // Fifo - delete first out
//     tabuList.erase(tabuList.begin());
//   }
// }


