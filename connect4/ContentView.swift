//
//  ContentView.swift
//  connect4
//
//  Created by Omar Habra on 3/8/22.
//

import Foundation
import SwiftUI

let rowCount = 6
let colCount = 7

enum Piece {
  case empty
  case player
  case opponent
}

typealias Board = [[Piece]]

enum PlayerResult {
  case success
  case end
  case error
}

struct ContentView: View {
  @State var board = Array<[Piece]>(repeating:
                                      Array<Piece>(repeating: .empty, count: colCount), count: rowCount)
  @State var won = Piece.empty
  @State var errorMessage: String? = nil
  
  var body: some View {
    if let errorMessage = errorMessage {
      VStack {
        Text(errorMessage)
        Button("Back") {
          self.errorMessage = nil
        }
      }
      .frame(width: 600, height: 600)
    } else if won == .player {
      Text("You won!")
        .frame(width: 600, height: 600)
    } else if won == .opponent {
      Text("AI won!")
        .frame(width: 600, height: 600)
    } else {
      VStack {
        HStack {
          ForEach(0..<colCount) { i in Button("⬇️") {
              play(atIndex: i)
            }
            .frame(maxWidth: .infinity)
          }
        }
        VStack {
          ForEach(board.reversed(), id: \.self) { array in
            HStack{
              ForEach(array, id: \.self) { element in
                Rectangle()
                  .frame(width: 75, height: 75)
                  .border(.black)
                  .foregroundColor(element == .empty ? .clear :
                                    element == .player ? .blue : .red)
              }
            }
          }
        }
      }
      .frame(width: 600, height: 600)
    }
  }
  
  /// Check if this row is full or if we can drop more coins.
  /// Parameter atColumn: the column to check.
  /// Returns: if there is any space left in the column.
  public func canDrop(atColumn col: Int) -> Bool {
    board[5][col] == .empty
  }
  
  /// Find the next open space in the column on the board.
  /// Parameter forColumn: the column to look through.
  /// Returns: the next open space in the given column or nil if there is not one.
  public func nextOpenRow(forColumn col: Int) -> Int? {
    for r in 0..<rowCount{
      if board[r][col] == .empty {
        return r
      }
    }
    
    return nil
  }
  
  /// Check if a given piece has four consecutive placements vertically, horizontally, or diagonoly.
  /// Parameter piece: the piece to check (either a player or the oppontent).
  /// Returns: if a piece has four consecutive
  public func didPieceWin(_ piece: Piece) -> Bool {
    // horizantally check
    for c in 0..<(colCount - 3) {
      for r in 0..<rowCount {
        if board[r][c] == piece &&
            board[r][c + 1] == piece &&
            board[r][c + 2] == piece &&
            board[r][c + 3] == piece { return true }
      }
    }
    
    // vertically check
    for c in 0..<colCount{
      for r in 0..<(rowCount - 3){
        if board[r][c] == piece &&
            board[r + 1][c] == piece &&
            board[r + 2][c] == piece &&
            board[r + 3][c] == piece { return true }
      }
    }
    
    // diagonally up
    for c in 0..<(colCount - 3){
      for r in 0..<(rowCount - 3){
        if board[r][c] == piece &&
            board[r + 1][c + 1] == piece &&
            board[r + 2][c + 2] == piece &&
            board[r + 3][c + 3] == piece { return true }
      }
    }
    
    // diagonally down
    for c in 0..<(colCount - 3){
      for r in 3..<(rowCount){
        if board[r][c] == piece &&
            board[r - 1][c + 1] == piece &&
            board[r - 2][c + 2] == piece &&
            board[r - 3][c + 3] == piece { return true }
      }
    }
    
    return false
  }
  
  private func play(atIndex index: Int) {
    assert(0 <= index && index <= rowCount)
    
    switch play(input: index, forPlayer: .player) {
    case .end:
      won = .player
      return
    case .error:
      errorMessage = "That column is full."
    case .success:
      break
    }
    
    let randCol = Int.random(in: 0..<rowCount)
    switch play(input: randCol, forPlayer: .opponent) {
    case .end:
      won = .opponent
      return
    case .error:
      errorMessage = "AI placed incorrectly"
    case .success:
      break
    }
  }
  
  private func play(input col: Int, forPlayer player: Piece) -> PlayerResult {
    if canDrop(atColumn: col) {
      guard let row = nextOpenRow(forColumn: col) else {
        print("Cannot place here")
        return .error
      }
      board[row][col] = player
      if didPieceWin(player) {
        print(player == .player ? "YOU WON!!!" : "AI won.")
        return .end
      }
      print(player == .player ? "you played" : "AI played")
      return .success
    }
    print("Can't drop here")
    return .error
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
