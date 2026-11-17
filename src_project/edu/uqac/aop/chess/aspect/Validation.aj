package edu.uqac.aop.chess.aspect;

import edu.uqac.aop.chess.Board;
import edu.uqac.aop.chess.Spot;
import edu.uqac.aop.chess.agent.*;
import edu.uqac.aop.chess.piece.*;

public privileged aspect Validation {

    pointcut playerMove(Player p, Move mv):
        execution(boolean Player+.makeMove(Move)) && this(p) && args(mv);

    // d) dans l'échiquier (+ coup nul)
    boolean around(Player p, Move mv): playerMove(p, mv) {
        if (mv == null || !in(mv.xI) || !in(mv.yI) || !in(mv.xF) || !in(mv.yF)
                || (mv.xI == mv.xF && mv.yI == mv.yF)) return false;
        return proceed(p, mv);
    }

    // a) case de départ non vide
    boolean around(Player p, Move mv): playerMove(p, mv) {
        if (!spot(p, mv.xI, mv.yI).isOccupied()) return false;
        return proceed(p, mv);
    }

    // b) la pièce appartient au joueur
    boolean around(Player p, Move mv): playerMove(p, mv) {
        if (spot(p, mv.xI, mv.yI).getPiece().getPlayer() != p.getColor()) return false;
        return proceed(p, mv);
    }

    // c) mouvement autorisé par la pièce
    boolean around(Player p, Move mv): playerMove(p, mv) {
        if (!spot(p, mv.xI, mv.yI).getPiece().isMoveLegal(mv)) return false;
        return proceed(p, mv);
    }

    // e) ne mange pas sa propre pièce
    boolean around(Player p, Move mv): playerMove(p, mv) {
        Spot dest = spot(p, mv.xF, mv.yF);
        if (dest.isOccupied() && dest.getPiece().getPlayer() == p.getColor()) return false;
        return proceed(p, mv);
    }

    // f) pas de saut, sauf cavalier
    boolean around(Player p, Move mv): playerMove(p, mv) {
        if (!(spot(p, mv.xI, mv.yI).getPiece() instanceof Knight)
                && !pathClear(p.playGround, mv)) return false;
        return proceed(p, mv);
    }

    // Règles du pion qui nécessitent le plateau
    boolean around(Player p, Move mv): playerMove(p, mv) {
        Piece pc = spot(p, mv.xI, mv.yI).getPiece();
        if (pc instanceof Pawn) {
            int dir = (pc.getPlayer() == Player.WHITE) ? 1 : -1;
            int startRow = (pc.getPlayer() == Player.WHITE) ? 1 : 6;
            int dx = Math.abs(mv.xF - mv.xI), dy = (mv.yF - mv.yI) * dir;
            boolean destOcc = spot(p, mv.xF, mv.yF).isOccupied();
            boolean ok = (dx == 0 && !destOcc && (dy == 1 || (dy == 2 && mv.yI == startRow)))
                      || (dx == 1 && dy == 1 && destOcc);
            if (!ok) return false;
        }
        return proceed(p, mv);
    }

    private static boolean in(int v) { return v >= 0 && v < Board.SIZE; }

    private static Spot spot(Player p, int x, int y) { return p.playGround.getGrid()[x][y]; }

    private static boolean pathClear(Board b, Move mv) {
        int dx = Integer.signum(mv.xF - mv.xI), dy = Integer.signum(mv.yF - mv.yI);
        int x = mv.xI + dx, y = mv.yI + dy;
        while (x != mv.xF || y != mv.yF) {
            if (b.getGrid()[x][y].isOccupied()) return false;
            x += dx; y += dy;
        }
        return true;
    }
}