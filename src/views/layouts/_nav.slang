- active = context.request.path == "/" ? "active" : ""
li.nav-item class=active
  a.nav-link href="/" Home
- active = context.request.path == "/disks" ? "active" : ""
li.nav-item class=active
  a class="nav-link" href="/disks" Disks
- active = context.request.path == "/meta_files" ? "active" : ""
li.nav-item class=active
  a class="nav-link" href="/meta_files" Meta Files
- active = context.request.path == "/node_files" ? "active" : ""
li.nav-item class=active
  a class="nav-link" href="/node_files" Node Files
