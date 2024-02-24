package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

const (
  m = 5
  n = 5
  k = 5
  maxMoves = 150
)

type Grid struct {
  mutex sync.Mutex
  grid [][]int // Krata z informacja o ilości podrózników,
  travelers int // AKtualna liczba podrózników
  travelerIDs []int // ID podrózników
}

var grid = make([][]Node, m)
var manager = TravelerManager{}

type Coordinate struct {
  X int
  Y int
}

type TravelerManager struct {
  next_id int
  mu sync.Mutex
}

type Request struct {
  t *Traveler
  l *Locator
  threat *Threat
  move [2]int
  leave bool
  isMove bool
  responseReady chan struct{}
}

type Response struct {
  allowed bool
  destroy bool
}

func server(node *Node) {
  for {
    var request = <-(*node).requests
    (*node).mu.Lock()
    if(request.t != nil) { // traveler request(implemented)
      node.handleTravelerReq(&request)
      // close(request.responseReady)
    } else if(request.l != nil) { // locator request(implemented)
      node.handleLocatorReq(&request)
    } else if(request.threat != nil) { // threat request(not implemented)
      node.handleThreatReq(&request)
    }
    (*node).mu.Unlock()
  }
}

func travelerMovement(traveler *Traveler, grid *[][]Node, maxMoves int) {
  for move := 0; move < maxMoves; move++ {
    traveler.move(grid) // function for moving this traveler
    time.Sleep(time.Duration(rand.Intn(10)) * 50 * time.Millisecond)
  }
}

func spawnTravelers(travelers *[]Traveler, grid *[][]Node, next_id *int, mu *sync.Mutex) {
  for {
    // fmt.Printf("Traveler count is %d", (*next_id));
    if (*next_id) < ((m * n) - 1) && rand.Intn(100) > 45 {
      mu.Lock()
      id := (*next_id)
      (*next_id)++
      mu.Unlock()
      spawnTraveler(travelers, grid, id, mu)
    }
    time.Sleep(time.Duration(180 * time.Millisecond))
  }
}

func spawnThreats(threats *[]Threat, grid *[][]Node, threat_id *int) {
  for {
    if (*threat_id) < ((m * n) - 1) && rand.Intn(100) < 15 {
      go spawnThreat(threats, grid, threat_id)
    }
    time.Sleep(time.Duration(220 * time.Millisecond))
  }
}

func spawnLocators(locators *[]Locator, grid *[][]Node, locator_id *int) {
  for {
    if (*locator_id) < ((m * n) - 1) && rand.Intn(100) < 20 {
      go spawnLocator(locators, grid, locator_id)
    }
    time.Sleep(time.Duration(270 * time.Millisecond))
  }
}

// Function for spawning new Traveler
func spawnTraveler(travelers *[]Traveler, grid *[][]Node, next_id int, mu *sync.Mutex) {
  var traveler Traveler
  for { // for loop until traveler is added 
    traveler.x = rand.Intn(m)
    traveler.y = rand.Intn(n)

    // responseReady := make(chan struct{})
    // Sending request to Node, {0, 0} informs that move was not made
    // (*grid)[traveler.x][traveler.y].mu.Lock()
    (*grid)[traveler.x][traveler.y].requests <- Request{t: &traveler, l: nil, threat: nil, move: [2]int{0, 0}, leave: false, isMove: false, responseReady: nil }
    // (*grid)[traveler.x][traveler.y].mu.Unlock()
    // <-responseReady

    var response = <-(*grid)[traveler.x][traveler.y].responses // Awaiting response from Node
    if(response.allowed) { // traveler added to grid
      fmt.Printf("Spawned new traveler of id + %d at (%d, %d)\n", (next_id), traveler.x, traveler.y);
      (*travelers)[(next_id)] = Traveler{id: (next_id), x: traveler.x, y: traveler.y}
      var traveler = &(*travelers)[(next_id)] 
      go travelerMovement(traveler, grid, maxMoves) // new thread for each added traveler
      // (*next_id)++ // Increment the id
      break
    }
  }
}

// Function for spawning new Locator
func spawnLocator(locators *[]Locator, grid *[][]Node, locator_id *int) {
  var x, y int
  (*locators)[(*locator_id)] = Locator{ id: (*locator_id), lifespan: 0, x : x, y: y, isDead: make(chan struct{})}
  var locator = &(*locators)[(*locator_id)]
  // for {
  (*locator).x = rand.Intn(m)
  (*locator).y = rand.Intn(n)
  (*locator).lifespan = 1 * time.Second // setting the lifespan of locator
  // Sending request to node
  (*grid)[locator.x][locator.y].requests <- Request{ t: nil, l: locator, threat: nil, move: [2]int{0, 0}, leave: false, isMove: false }
  var response = <- (*grid)[locator.x][locator.y].responses
  if(response.allowed) {
    fmt.Printf("Dodano nowego lokatora o id %d na pozycji (%d, %d)\n", (*locator_id), locator.x, locator.y)    
    // Osobny wątek do monitorowania czasu zycia danego lokatora
    go locator.monitorLifespan(grid) 
    (*locator_id)++
  }
}

// Function for spawning new Threat
func spawnThreat(threats *[]Threat, grid *[][]Node, threat_id *int) {
  var x, y int
  (*threats)[(*threat_id)] = Threat{ id: (*threat_id), z: 0, x: x, y: y, isAlive: make(chan struct{}) }
  var threat = &(*threats)[(*threat_id)]
  (*threat).x = rand.Intn(m)
  (*threat).y = rand.Intn(n)
  (*threat).z = 2 * time.Second // setting the lifespan of threat
  // Sending request to node
  (*grid)[threat.x][threat.y].requests <- Request{ t: nil, l: nil, threat: threat, move: [2]int{0, 0}, leave: false, isMove: false }
  var res = <- (*grid)[threat.x][threat.y].responses
  if(res.allowed) {
    fmt.Printf("Dodano nowe zagrozenie o id %d na pozycji (%d, %d)\n", (*threat_id), threat.x, threat.y)
    go threat.monitorLifespan(grid)
    (*threat_id)++
  }
}

func snap(move int, grid *[][]Node) {
  fmt.Println("Move:", move)

  for i := 0; i < m; i++ {
    for j := 0; j < n; j++ {
      fmt.Print("\x1b[0m")
      if((*grid)[i][j].threat != nil) {
        fmt.Printf("%2s", "#")
      } else if((*grid)[i][j].occupied && (*grid)[i][j].threat == nil) {
        if(*grid)[i][j].locator != nil {
          fmt.Printf("%2s", "*")
        } else {
          fmt.Printf("%2d", (*grid)[i][j].traveler.id)
        }
      } else if(!(*grid)[i][j].occupied) {
        fmt.Print("  ")
      }
      
      if(*grid)[i][j].from_side == 1 {
        fmt.Print("\x1b[31m")
      } else {
        fmt.Print("\x1b[0m")
      }
      fmt.Print("|")
    }
    fmt.Println()
    for k := 0; k < n; k++ {
      if(*grid)[i][k].from_below == 1 {
        fmt.Print("\x1b[31m")
      } else {
        fmt.Print("\x1b[0m")
      }
      fmt.Print("---")
    }
    fmt.Println()
  }
  fmt.Println()
  
  for i := 0; i < m; i++ {
    for j := 0; j < n; j++ {
      (*grid)[i][j].from_side = -1
      (*grid)[i][j].from_below = -1
    }
  }
}

func snapshot(grid *[][]Node, moves int) {
  for move := 0; move < moves; move++ {
    time.Sleep(200 * time.Millisecond)
    snap(move, grid)
  }
}

func main() {
  rand.NewSource(time.Now().UnixNano())
  for i := range grid {
    grid[i] = make([]Node, n)
  }
  // New thread for each Node and creating grid of Nodes
  var wg sync.WaitGroup
  // wg.Add(m * n)

  for i := 0; i < m; i++ {
    for j := 0; j < n; j++ {
      fmt.Printf("%d", j)
      var requests = make(chan Request)
      var responses = make(chan Response)
      grid[i][j].requests = requests
      grid[i][j].responses = responses
      grid[i][j].occupied = false
      grid[i][j].x = i
      grid[i][j].y = j
      grid[i][j].locator = nil
      grid[i][j].threat = nil
      grid[i][j].traveler = nil
      go func(i int, j int) {
        // defer wg.Done()
        server(&grid[i][j]) // new thread for each Node
      }(i, j)
      // go server(&grid[i][j]) // new thread for each Node
    }
  }
  // wg.Wait()


  var next_id = 0;
  var locator_id = 0
  var threat_id = 0;
  travelers := make([]Traveler, (m * n) - 1)
  locators := make([]Locator, (m * n) - 1)
  threats := make([]Threat, (m * n) - 1)

  mu := &sync.Mutex{}

  // Adding k travelers at the start of simulation
  for i := 0; i < k; i++ { 
    wg.Add(1)
    go func() {
      defer wg.Done()
      mu.Lock()
      id := next_id
      next_id++
      mu.Unlock()
      spawnTraveler(&travelers, &grid, id, mu) 
    }()
    // spawnTraveler(&travelers, &grid, &next_id) 
  }

  wg.Wait()
  fmt.Println("HEy brother")
  fmt.Printf("Next id is %d\n", next_id)

  for i := 0; i < k; i++ {
    wg.Add(1)
    id := i
    go func(id int) {
      defer wg.Done()
      fmt.Printf("Moving traveler of id %d\n", id)
      travelerMovement(&travelers[id], &grid, maxMoves) 
    }(id)
    // go travelerMovement(&travelers[i], &grid, maxMoves) 
  }

  wg.Wait()
  fmt.Println("HEy sister")

  go spawnTravelers(&travelers, &grid, &next_id, mu) // thread for spawning new travelers
  go spawnLocators(&locators, &grid, &locator_id) // thread for spawning locators

  go spawnThreats(&threats, &grid, &threat_id) // thread for spawning threats
  go snapshot(&grid, maxMoves) // thread for system's snapshot(camera)

  time.Sleep(15 * time.Second)
}