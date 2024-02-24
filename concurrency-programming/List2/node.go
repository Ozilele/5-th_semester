package main

import (
	"fmt"
	"math"
	"sync"
)

type Node struct {
  x, y int
  mu sync.Mutex
  traveler *Traveler
  locator *Locator
  threat *Threat
  occupied bool // occupied by the other traveler
  from_below int
  from_side  int
  requests chan Request // requests received by the node(from traveler, lokator, threat)
  responses chan Response // responses given by the node(traveler changed its position, lokator appeared in the node, threat appeared in the node)
}

// function for checking if traveler is moving from the neighboured node
func (node *Node) isNeighbour(traveler *Traveler) bool {
  var travelerX, travelerY = traveler.x, traveler.y;
  if(math.Abs((float64(node.x - travelerX))) > 1) {
    return false
  } 
  if(math.Abs(float64(node.y - travelerY)) > 1) {
    return false
  }
  if( math.Abs(float64(node.x - travelerX)) == 1 && math.Abs(float64(node.y - travelerY)) == 1 ) {
    return false // wykluczenie wspolrzednych na ukos
  }
  if((travelerX == node.x) && (travelerY == node.y)) {
    return false
  }
  return true
}

func (node *Node) findEmptyNeighbour(x int, y int) *Node {
  // fmt.Printf("podano dane w postaci (%d, %d)\n", x, y)
  directions := [][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
  // var newNode *Node = nil
  for _, dir := range directions {
    newX, newY := node.x + dir[0], node.y + dir[1]
    if(newX >= 0 && newX < m && newY >= 0 && newY < n) {
      candidateNode := &grid[newX][newY]
      if(candidateNode != nil && !candidateNode.occupied && (candidateNode.x != x || candidateNode.y != y)) {
        // fmt.Printf("Proponowanym nodem jest node (%d, %d)\n", candidateNode.x, candidateNode.y)
        return candidateNode
      }
    }
  }
  return nil
}

func (node *Node) handleTravelerReq(request *Request) {
  if((*request).leave) { // Node wants to be deleted
    // (*node).mu.Lock()
    (*node).occupied = false
    (*node).traveler = nil;
    (*node).responses <- Response{ allowed: true }

    if((*request).move[0] != 0) {
      if(node.x < (*request).t.x) {
        (*node).from_side = 1
      }
    } else {
      if(node.y < (*request).t.y) {
        (*node).from_below = 1
      }
    }
    // (*node).mu.Unlock()
  } else { // Node wants to be added or moved
    var traveler = (*request).t;
    var oldTravelerX, oldTravelerY = traveler.x, traveler.y

    if(node.occupied && (*node).locator == nil) { // Node is occupied by other traveler and locator is not in node
      // (*node).mu.Lock()
      (*node).responses <- Response{ allowed: false }
      // (*node).mu.Unlock()
    } else {

      if((*node).locator != nil) { // Dziki lokator jest w wierzchołku
        if(!(*node).isNeighbour(traveler)) {
          // podroznik nie przemieszcza sie z sasiedniego wierzcholka
          // (*node).mu.Lock()
          (*node).responses <- Response{ allowed: false }
          // (*node).mu.Unlock()
          return
        } else {
          var locator = (*node).locator;
          newNode := node.findEmptyNeighbour(oldTravelerX, oldTravelerY);
          if(newNode == nil) {
            // nie znaleziono sasiedniego pustego wierzcholka, traveler nie moze sie wprowadzic
            // (*node).mu.Lock()
            (*node).responses <- Response{ allowed: false } 
            // (*node).mu.Unlock()
            return
          } else { 
            var deltaMoveX, deltaMoveY = newNode.x - oldTravelerX, newNode.y - oldTravelerY
            // Lokator sie przeprowadza
            newNode.requests <- Request{ t: nil, l: locator, threat: nil, move: [2]int{deltaMoveX, deltaMoveY}, leave: false, isMove: true }
            var locatorResponse = <- newNode.responses
            if locatorResponse.allowed { 
              fmt.Printf("Lokator o id %d po przeprowadzce na wierzchołek (%d, %d)\n", locator.id, newNode.x, newNode.y)
              // po przeprowadzce lokator jest usuwany z obecnego wierzchołka
              // (*node).mu.Lock()
              (*node).locator = nil;

              (*node).occupied = true
              (*node).traveler = traveler;
              (*node).traveler.x = node.x
              (*node).traveler.y = node.y

              if(request.move[0] != 0) {
                if(node.x < oldTravelerX) {
                  (*node).from_side = 1
                }
              } else {
                if(node.y < oldTravelerY) {
                  (*node).from_below = 1
                }
              }
              (*node).responses <- Response{ allowed: true }
              // (*node).mu.Unlock()
              return
            }
          }
        }
      }

      if((*node).threat != nil && !node.occupied) {
        fmt.Printf("Traveler o id %d natknął się na zagrozenie na (%d, %d) - usuwanie zagrozenia oraz travelera\n", traveler.id, (*node).x, (*node).y)
        // (*node).mu.Lock()
        (*node).threat.isAlive <- struct{}{} // zamknięcie kanału dotyczącego zywotnosci zagrozenia
        (*node).threat = nil
        (*node).traveler = nil
        (*node).occupied = false
        (*node).responses <- Response{ destroy: true } // response with info that traveler needs to be destroyed
        // (*node).mu.Unlock()
        return
      }

      if(node.occupied) { // Node occupied by locator or traveler
        // (*node).mu.Lock()
        (*node).responses <- Response{ allowed: false }
        // (*node).mu.Unlock()
        return
      }

      if((*node).threat == nil && !node.occupied) {
        // (*node).mu.Lock()
        (*node).occupied = true
        (*node).traveler = traveler;
        (*node).traveler.x = node.x
        (*node).traveler.y = node.y
      
        if(request.move[0] != 0) {
          if(node.x < oldTravelerX) {
            (*node).from_side = 1
          }
        } else {
          if(node.y < oldTravelerY) {
            (*node).from_below = 1
          }
        }
        (*node).responses <- Response{ allowed: true }
        // (*node).mu.Unlock()
      }
    }
  }
}

func (node *Node) handleLocatorReq(request *Request) {
  if((*request).leave) { 
    (*node).occupied = false;
    (*node).locator = nil;
    (*node).responses <- Response{ allowed: true }

    if((*request).move[0] != 0) {
      if(node.x < (*request).l.x) {
        (*node).from_side = 1
      }
    } else {
      if(node.y < (*request).l.y) {
        (*node).from_below = 1
      }
    }
  } else { // locator wants to be added or moved
    locator := (*request).l
    var oldLocatorX, oldLocatorY = locator.x, locator.y
    if(request.isMove) { // locator is going to be moved to adjacent empty node
      (*node).occupied = true
      (*node).locator = locator
      (*node).locator.x = node.x
      (*node).locator.y = node.y

      if(request.move[0] != 0) {
        if(node.x < oldLocatorX) {
          (*node).from_side = 1
        }
      } else {
        if(node.y < oldLocatorY) {
          (*node).from_below = 1
        }
      }

      (*node).responses <- Response{ allowed: true }
    } else { // adding locator
      if((*node).locator != nil) {
        (*node).responses <- Response{ allowed: false } // locator is already in node
      } else {
        (*node).traveler = nil
        (*node).threat = nil

        (*node).occupied = true
        (*node).locator = locator

        if(request.move[0] != 0) {
          if(node.x < oldLocatorX) {
            (*node).from_side = 1
          }
        } else {
          if(node.y < oldLocatorY) {
            (*node).from_below = 1
          }
        }
        (*node).responses <- Response{ allowed: true }
      }
    }
  }
}

func (node *Node) handleThreatReq(request *Request) {
  if((*request).leave) {
    (*node).threat = nil
    (*node).responses <- Response{ allowed: true }

    if((*request).move[0] != 0) {
      if(node.x < (*request).threat.x) {
        (*node).from_side = 1
      }
    } else {
      if(node.y < (*request).threat.y) {
        (*node).from_below = 1
      }
    }
  } else { // threat wants to be added
    threat := (*request).threat
    var oldThreatX, oldThreatY = threat.x, threat.y

    // Usuniecie z node travelera i locatora
    (*node).occupied = false
    (*node).traveler = nil
    (*node).locator = nil

    (*node).threat = threat
    (*node).threat.x = node.x
    (*node).threat.y = node.y

    if(request.move[0] != 0) {
      if(node.x < oldThreatX) {
        (*node).from_side = 1
      }
    } else {
      if(node.y < oldThreatY) {
        (*node).from_below = 1
      }
    }
    (*node).responses <- Response{ allowed: true }
  }
}