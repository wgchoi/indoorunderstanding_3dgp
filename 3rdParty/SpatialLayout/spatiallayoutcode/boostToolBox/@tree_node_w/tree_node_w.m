%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   tree_node_w Implements the constructor for tree_node_w class, that
%   imlements classification tree
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    tree_node = tree_node_w(max_split)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           max_split - maximum number of splits in the tree
%    Return:
%           tree_node - object of tree_node_w class

function tree_node = tree_node_w(max_split)

tree_node.left_constrain  = [];
tree_node.right_constrain = [];
tree_node.dim             = [];
tree_node.max_split       = max_split;
tree_node.parent         = [];

tree_node = class(tree_node, 'tree_node_w') ;