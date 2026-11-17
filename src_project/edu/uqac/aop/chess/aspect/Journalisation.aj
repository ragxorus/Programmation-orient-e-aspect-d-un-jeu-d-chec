package edu.uqac.aop.chess.aspect;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import edu.uqac.aop.chess.agent.Move;
import edu.uqac.aop.chess.agent.Player;

public aspect Journalisation {

    private static final String LOG_FILE = "moves.log";

    declare precedence: Validation, Journalisation;

    after(Move mv) returning(boolean ok):
            execution(boolean Player+.makeMove(Move)) && args(mv) {
        if (!ok) return;
        try (PrintWriter w = new PrintWriter(new FileWriter(LOG_FILE, true))) {
            w.println("" + (char) ('a' + mv.xI) + (mv.yI + 1)
                    + (char) ('a' + mv.xF) + (mv.yF + 1));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}