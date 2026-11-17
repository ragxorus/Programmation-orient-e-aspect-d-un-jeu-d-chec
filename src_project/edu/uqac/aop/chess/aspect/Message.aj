package edu.uqac.aop.chess.aspect;

import edu.uqac.aop.chess.agent.HumanPlayer;
import edu.uqac.aop.chess.agent.Move;

public aspect Message {

    after(Move mv) returning(boolean ok):
            execution(boolean HumanPlayer.makeMove(Move)) && args(mv) {
        if (!ok) {
            System.out.println("Coup illégal, veuillez rejouer.");
        }
    }
}