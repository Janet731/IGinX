/*
 * IGinX - the polystore system with high performance
 * Copyright (C) Tsinghua University
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package cn.edu.tsinghua.iginx.metadata.entity;

import cn.edu.tsinghua.iginx.thrift.UDFType;
import java.util.Set;

public class TransformTaskMeta {

  private String name;

  private String className;

  private String fileName;

  private Set<String> ipSet;

  private UDFType type;

  public TransformTaskMeta(
      String name, String className, String fileName, Set<String> ipSet, UDFType type) {
    this.name = name;
    this.className = className;
    this.fileName = fileName;
    this.ipSet = ipSet;
    this.type = type;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getClassName() {
    return className;
  }

  public void setClassName(String className) {
    this.className = className;
  }

  public String getFileName() {
    return fileName;
  }

  public void setFileName(String fileName) {
    this.fileName = fileName;
  }

  public Set<String> getIpSet() {
    return ipSet;
  }

  public void setIpSet(Set<String> ipSet) {
    this.ipSet = ipSet;
  }

  public void addIp(String ip) {
    this.ipSet.add(ip);
  }

  public UDFType getType() {
    return type;
  }

  public void setType(UDFType type) {
    this.type = type;
  }

  public TransformTaskMeta copy() {
    return new TransformTaskMeta(name, className, fileName, ipSet, type);
  }

  @Override
  public String toString() {
    return "TransformTaskMeta{"
        + "name='"
        + name
        + '\''
        + ", className='"
        + className
        + '\''
        + ", fileName='"
        + fileName
        + '\''
        + ", ip='"
        + ipSet
        + '\''
        + ", type="
        + type
        + '}';
  }
}
